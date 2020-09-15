#!/bin/bash 
set -x
set -e
set -o pipefail

#
# General definitions
#
declare -r SUDO_CMD="sudo -E" # Save environment variables if they exist
declare -r PACKAGES_TO_INSTALL=(
  "wget"
)

#
# General work towards functioning system goes here
#
$SUDO_CMD yum -y install ${PACKAGES_TO_INSTALL[@]} >/dev/null

cd /tmp
wget https://s3.amazonaws.com/amazoncloudwatch-agent/centos/amd64/latest/amazon-cloudwatch-agent.rpm
$SUDO_CMD rpm -U ./amazon-cloudwatch-agent.rpm

# Create CloudWatch Machine Metrics Config file.
cat > "/opt/aws/amazon-cloudwatch-agent/etc/config.json" << EOF
{
        "agent": {
                "metrics_collection_interval": 60,
                "run_as_user": "cwagent"
        },
        "metrics": {
        		"namespace": "CustomMachineMetrics",
                "append_dimensions": {
                        "AutoScalingGroupName": "\${aws:AutoScalingGroupName}",
                        "ImageId": "\${aws:ImageId}",
                        "InstanceId": "\${aws:InstanceId}",
                        "InstanceType": "\${aws:InstanceType}"
                },
                "metrics_collected": {
                        "cpu": {
                                "measurement": [
                                    "cpu_usage_active",
                                    "cpu_usage_guest",
                                    "cpu_time_active"
                                ],
                                "metrics_aggregation_interval": 60,
                                "resources": [
                                        "*"
                                ]
                        },
                        "disk": {
                                "measurement": [
                                    "disk_used_percent"
                                ],
                                "metrics_collection_interval": 60,
                                "resources": [
                                        "*"
                                ]
                        },
                        "mem": {
                                "measurement": [
                                    "mem_used_percent"
                                ],
                                "metrics_collection_interval": 60
                        },
                        "swap": {
                        		"measurement": [
    	                             "swap_used_percent"
                                ]
                        }
                }
        }
}
EOF

# Start cloudwatch agent using above config.
$SUDO_CMD /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json -s
$SUDO_CMD systemctl enable amazon-cloudwatch-agent.service

