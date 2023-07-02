# Copy rabia binary to all machines

reset_directory="rm -r /home/ubuntu/rabia; mkdir /home/ubuntu/rabia"
kill_insstances="pkill rabia ; pkill rabia; pkill rabia"

cert="/home/pasindu/Documents/rabia/experiments/remote/private_key_aws/pasindu2023.pem"

replica1=ubuntu@ec2-34-224-78-11.compute-1.amazonaws.com
replica2=ubuntu@ec2-18-207-143-224.compute-1.amazonaws.com
replica3=ubuntu@ec2-54-90-145-152.compute-1.amazonaws.com
replica4=ubuntu@ec2-184-72-141-58.compute-1.amazonaws.com
replica5=ubuntu@ec2-54-91-91-186.compute-1.amazonaws.com

client1=ubuntu@ec2-3-95-239-214.compute-1.amazonaws.com
client2=ubuntu@ec2-34-239-247-39.compute-1.amazonaws.com
client3=ubuntu@ec2-54-227-84-218.compute-1.amazonaws.com
client4=ubuntu@ec2-54-82-109-207.compute-1.amazonaws.com
client5=ubuntu@ec2-3-87-78-76.compute-1.amazonaws.com

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