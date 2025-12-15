#!/bin/bash
# Tell the system to execute this script as bash.


# monitor-server.sh

# Remote monitoring script that is able to collect CPU, RAM, I/O, Network and Load and write them in a CSV file used for quantitative data collection during stress-testing.


# Start a new ssh-agent and export its environment variables, this keeps the agent in memory, removing the need of logging in multiple times.
eval "$(ssh-agent -s)"

# Add the private ssh key to the agent (this will ask for the passphrase once, so that it will not ask for each capture)
ssh-add /home/ubuntu/.ssh/id_rsa


# Variables declaration

# Remote server username
SERVER_USER="fedora"

# Remote server IP
SERVER_IP="192.168.0.100"

# SSH port of the server
SSH_PORT="9876"

# Path to the private SSH key
KEY="/home/ubuntu/.ssh/id_rsa"

# Interval between samples (seconds)
INTERVAL="1"

# Total amount of data collected
SAMPLES="30"

# CSV file name
CSV_FILE="server_metrics.csv"


# CSV initialization, if the CSV file does not exist, create one and add headers
if [ ! -f "$CSV_FILE" ]; then
	echo "Timestamp,CPU_User,CPU_System,CPU_Idle,Mem_Used_MB,Mem_Free_MB,Mem_Buffers_MB,Disk_r/s,Disk_w/s,Disk_rMB/s,Disk_wMB/s,Net_RX_KB/s,Net_TX_KB/s,Load1,Disk_Read_Latency_ms,Disk_Write_Latency_ms,Net_Latency_ms" > "$CSV_FILE"
fi

# Function collect_data collects all metrics (CPU, RAM, I/O, Network and Load)
collect_data() {

	# Use ssh using the key, port and user@ip grouping all commands in a grouped EOF (End Of File for multiline commands) to call them in one sitting. 
	# -i : private key
	# -p : custom port
	ssh -i "$KEY" -p "$SSH_PORT" "$SERVER_USER@$SERVER_IP" bash -s << 'EOF'
	
	# Use high priority for monitoring commands
	# nice: sets CPU scheduling priority (0 = normal priority, as -10 requires root access)
	NICE_CMD="nice -n 0"
	# ionice: sets I/O scheduling priority (class 2 = best-effort, priority 0)
	IONICE_CMD="ionice -c2 -n0"

	# Get date and time
	TS=$(date '+%Y-%m-%d %H:%M:%S')

	# CPU usage (user, system, and idle CPU percentages)
	# Run top twice (-n2) to discard the first reading (as the first reading always throws rubbish data), together with the nice and ionice command.
	# The awk command fetches the first line containing the word Cpu, then split the line by a space, and get the third, fifth and ninth element. (user, system and idle)
	# If no lines have been found, return 0 for each metric.
	CPU=$($NICE_CMD $IONICE_CMD top -bn2 | \
		awk '/Cpu\(s\)/ {line=$0} END {
			if(line){split(line,a," "); 
				print a[2]","a[4]","a[8]
			} else {
				print "0,0,0"
			}
		}')

	# Memory usage (used, free, and buffer/cache memory)
	# , together with the nice and ionice command.
	# Check if Number of Records is equal to two (second line exists). If if does exists, we have data, hence, return the data as pictured below.

	#                total   used   free   shared   buff/cache   available
	# Mem:           7846   2310   3210      112          2325        5200
	# Swap:          2047      0   2047

	MEM=$($NICE_CMD $IONICE_CMD free -m | \
		awk 'NR==2 {
			printf "%s,%s,%s", $3,$4,$6
		} END {
			if(NR<2) print "0,0,0"
		}')


	# Disk I/O ()
	# Find the first non-loop, non-RAM disk device
	# '$3 !~ /loop|ram/' (regex) takes only devices whose name does NOT contain “loop” or “ram”.
	# /proc/diskstats contains a line for every block device, where the regex has effect.
	# Once found, output the device name and exit
	DISK_NAME=$(awk '{if($3 !~ /loop|ram/) {print $3; exit}}' /proc/diskstats)

	# If the file exists
	if [ -n "$DISK_NAME" ]; then


		DISK=$($NICE_CMD $IONICE_CMD awk -v d="$DISK_NAME" '
			$3==d {
				printf "%s,%s,%s,%s",
				$4,$8,$4/1024,$8/1024
			}' /proc/diskstats)

		
		# Total number of read operations completed
		read_ops=$(awk -v d="$DISK_NAME" '$3==d {print $4}' /proc/diskstats)
		# Total number of write operations completed
		write_ops=$(awk -v d="$DISK_NAME" '$3==d {print $8}' /proc/diskstats)
		# Total time spent reading (milliseconds)
		read_ms=$(awk -v d="$DISK_NAME" '$3==d {print $7}' /proc/diskstats)
		# Total time spent writing (milliseconds)
		write_ms=$(awk -v d="$DISK_NAME" '$3==d {print $11}' /proc/diskstats)

		# Initialise latency values
		read_latency=0
		write_latency=0
		
		# Calculate read latency by dividing operations completed with the time spent writing/reading (if greater than zero -gt 0)
		if [ "$read_ops" -gt 0 ]; then
			# scale=2 tells the calculator to trim to two decimals
			# | bc tells the system to use a floating point calculator
			read_latency=$(echo "scale=2; $read_ms / $read_ops" | bc)
		fi
		if [ "$write_ops" -gt 0 ]; then
			# scale=2 tells the calculator to trim to two decimals
			# | bc tells the system to use a floating point calculator
			write_latency=$(echo "scale=2; $write_ms / $write_ops" | bc)
		fi
	else
		# No disk has been detected, provide empty values
		DISK="0,0,0,0"
		read_latency=0
		write_latency=0
	fi

	# Network throughput

	if [ -n "enp0s8" ]; then
		NET=$($NICE_CMD $IONICE_CMD awk -v iface="enp0s8" '$1 ~ iface {rx=$2/1024; tx=$10/1024; print rx "," tx}' /proc/net/dev)
	else
		NET="0,0"
	fi

	# Network latency (ping localhost, ms)
	NET_LATENCY=$(ping -c1 -W1 127.0.0.1 | awk -F'=' '/time=/{split($4,a," "); print a[1]}')
	if [ -z "$NET_LATENCY" ]; then
		NET_LATENCY=0
	fi

	# Load
	LOAD=$(uptime | awk -F'load average:' '{if($2) print $2; else print "0"}' | awk -F',' '{gsub(/ /,""); print $1}')

	echo "$TS,$CPU,$MEM,$DISK,$NET,$LOAD,$read_latency,$write_latency,$NET_LATENCY"
EOF
}

# ------------------------ MAIN SCRIPT ------------------------
echo "Starting remote server monitoring..."
echo "Collecting $SAMPLES samples."

for ((i=1; i<=SAMPLES; i++)); do
	echo "Collecting sample $i/$SAMPLES..."
	# Append metrics to CSV
	collect_data >> "$CSV_FILE"   
	sleep "$INTERVAL"
done

echo "Action complete. Data saved to $CSV_FILE"
