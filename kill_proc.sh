# name="basic"
# name="auto-scaling-demo"
# name=$1
name="postgres-operator"
echo name: $name
dir_path="kustomize"
echo dir_path: $dir_path

# Stop port forwarding
kill `pgrep kubectl`
# pgrep -alf kubectl

# Delete the hasura cluster
kubectl -n $name delete -f ../hasura

# Delete the postgres cluster
kubectl -n $name delete -k $dir_path/monitoring
kubectl -n $name delete -k $dir_path/postgres
kubectl -n $name delete -k $dir_path/install

# delete container all.
docker rm -f `docker ps -a -q -f status=exited`