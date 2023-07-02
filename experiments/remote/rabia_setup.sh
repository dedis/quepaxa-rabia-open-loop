# Copy rabia binary to all machines

reset_directory="rm -r /home/ubuntu/rabia; mkdir /home/ubuntu/rabia"
kill_insstances="pkill rabia ; pkill rabia; pkill rabia"

cert="/home/pasindu/Documents/rabia/experiments/remote/private_key_aws/pasindu2023.pem"

replica1=ubuntu@ec2-54-94-113-24.sa-east-1.compute.amazonaws.com
replica2=ubuntu@ec2-54-178-123-123.ap-northeast-1.compute.amazonaws.com
replica3=ubuntu@ec2-13-233-14-202.ap-south-1.compute.amazonaws.com
replica4=ubuntu@ec2-3-1-5-83.ap-southeast-1.compute.amazonaws.com
replica5=ubuntu@ec2-34-247-105-45.eu-west-1.compute.amazonaws.com

client1=ubuntu@ec2-15-228-241-95.sa-east-1.compute.amazonaws.com
client2=ubuntu@ec2-18-181-182-155.ap-northeast-1.compute.amazonaws.com
client3=ubuntu@ec2-3-108-41-221.ap-south-1.compute.amazonaws.com
client4=ubuntu@ec2-54-179-70-76.ap-southeast-1.compute.amazonaws.com
client5=ubuntu@ec2-3-249-212-182.eu-west-1.compute.amazonaws.com

local_replica_path="rabia"
local_client_path="rabia"

remote_home_path="/home/ubuntu/rabia/"

echo "Replica 1"
sshpass ssh -o "StrictHostKeyChecking no" ${replica1} -i ${cert} "${reset_directory}"
sshpass ssh -o "StrictHostKeyChecking no" ${replica1} -i ${cert} "${kill_insstances}"
scp -i ${cert} ${local_replica_path} ${replica1}:${remote_home_path}

echo "Replica 2"
sshpass ssh -o "StrictHostKeyChecking no" ${replica2} -i ${cert} "${reset_directory}"
sshpass ssh -o "StrictHostKeyChecking no" ${replica2} -i ${cert} "${kill_insstances}"
scp -i ${cert} ${local_replica_path} ${replica2}:${remote_home_path}

echo "Replica 3"
sshpass ssh -o "StrictHostKeyChecking no" ${replica3} -i ${cert} "${reset_directory}"
sshpass ssh -o "StrictHostKeyChecking no" ${replica3} -i ${cert} "${kill_insstances}"
scp -i ${cert} ${local_replica_path} ${replica3}:${remote_home_path}

echo "Replica 4"
sshpass ssh -o "StrictHostKeyChecking no" ${replica4} -i ${cert} "${reset_directory}"
sshpass ssh -o "StrictHostKeyChecking no" ${replica4} -i ${cert} "${kill_insstances}"
scp -i ${cert} ${local_replica_path} ${replica4}:${remote_home_path}

echo "Replica 5"
sshpass ssh -o "StrictHostKeyChecking no" ${replica5} -i ${cert} "${reset_directory}"
sshpass ssh -o "StrictHostKeyChecking no" ${replica5} -i ${cert} "${kill_insstances}"
scp -i ${cert} ${local_replica_path} ${replica5}:${remote_home_path}

echo "Client 1"
sshpass ssh -o "StrictHostKeyChecking no" ${client1} -i ${cert} "${reset_directory}"
sshpass ssh -o "StrictHostKeyChecking no" ${client1} -i ${cert} "${kill_insstances}"
scp -i ${cert} ${local_client_path} ${client1}:${remote_home_path}

echo "Client 2"
sshpass ssh -o "StrictHostKeyChecking no" ${client2} -i ${cert} "${reset_directory}"
sshpass ssh -o "StrictHostKeyChecking no" ${client2} -i ${cert} "${kill_insstances}"
scp -i ${cert} ${local_client_path} ${client2}:${remote_home_path}

echo "Client 3"
sshpass ssh -o "StrictHostKeyChecking no" ${client3} -i ${cert} "${reset_directory}"
sshpass ssh -o "StrictHostKeyChecking no" ${client3} -i ${cert} "${kill_insstances}"
scp -i ${cert} ${local_client_path} ${client3}:${remote_home_path}

echo "Client 4"
sshpass ssh -o "StrictHostKeyChecking no" ${client4} -i ${cert} "${reset_directory}"
sshpass ssh -o "StrictHostKeyChecking no" ${client4} -i ${cert} "${kill_insstances}"
scp -i ${cert} ${local_client_path} ${client4}:${remote_home_path}

echo "Client 5"
sshpass ssh -o "StrictHostKeyChecking no" ${client5} -i ${cert} "${reset_directory}"
sshpass ssh -o "StrictHostKeyChecking no" ${client5} -i ${cert} "${kill_insstances}"
scp -i ${cert} ${local_client_path} ${client5}:${remote_home_path}

echo "setup complete"