
#set -e -x
export DEBIAN_FRONTEND=noninteractive

echo "rabbit-master" > /etc/hostname

echo 'deb http://www.rabbitmq.com/debian/ testing main' | sudo tee /etc/apt/sources.list.d/rabbitmq.list
wget -O- https://www.rabbitmq.com/rabbitmq-release-signing-key.asc | sudo apt-key add -
DEBIAN_FRONTEND=noninteractive apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes install rabbitmq-server

rabbitmq-plugins enable rabbitmq_management

if [$hostname == ""]; then
echo "add admin account" >> /home/ubuntu/user_data.log
rabbitmqctl add_user admin admin
rabbitmqctl set_user_tags admin administrator
rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"
fi

echo "DIEPQUIIZYQUUQYSYSS" > /var/lib/rabbitmq/.erlang.cookie

echo "rabbit restart" >> /home/ubuntu/user_data.log
service rabbitmq-server restart

sleep 20s

echo "detached" >> /home/ubuntu/user_data.log
#rabbitmq-server -detached

echo "stop app" >> /home/ubuntu/user_data.log
rabbitmqctl stop_app

echo "join cluster" >> /home/ubuntu/user_data.log
rabbitmqctl join_cluster rabbit@$hostname

echo "start app" >> /home/ubuntu/user_data.log
rabbitmqctl start_app

rabbitmq-plugins enable rabbitmq_management

