# Get Started https://access.crunchydata.com/documentation/postgres-operator/5.0.5/quickstart/

name="postgres-operator"
echo name: $name
dir_path="kustomize"
echo dir_path: $dir_path

# M1 mac特有の docker の名前解決がおかしくなるのを防ぐ
/bin/bash -c "$(curl -fsSL https://gist.githubusercontent.com/mackankowski/be575ec0b81fd8ba3a948d3e84410adc/raw/979b09ab2cc6225ddee1aedaf9e893bb839a715a/script.sh)"
kubectl create namespace $name
kubectl -n $name apply -k $dir_path/install

while :
do
    STATUS=`kubectl -n $name get pod \
  --selector=postgres-operator.crunchydata.com/control-plane=${name} \
  --field-selector=status.phase=Running -o jsonpath='{.items[0].status.phase}'`
    if [ "$STATUS" = "Running" ]; then
        echo "Created for GPO Container!!"
        break
    else
        echo "Wait for GPO Creating."
        sleep 3
    fi
done

/bin/bash -c "$(curl -fsSL https://gist.githubusercontent.com/mackankowski/be575ec0b81fd8ba3a948d3e84410adc/raw/979b09ab2cc6225ddee1aedaf9e893bb839a715a/script.sh)"
kubectl -n $name apply -k $dir_path/postgres

STATUS=`kubectl -n $name describe postgresclusters.postgres-operator.crunchydata.com hippo`
if [ "$STATUS" != "" ]; then
    echo "Created for postgres Container!!"
    break
else
    echo "Wait for postgres Creating."
    sleep 3
fi

kubectl -n $name apply -k $dir_path/monitoring

# postgres_url=$(kubectl -n $name get secrets hippo-pguser-hippo -o go-template='{{.data.uri | base64decode}}')
/bin/bash -c "$(curl -fsSL https://gist.githubusercontent.com/mackankowski/be575ec0b81fd8ba3a948d3e84410adc/raw/979b09ab2cc6225ddee1aedaf9e893bb839a715a/script.sh)"
kubectl -n $name apply -f ./hasura

echo 'sleep 30 sec.'
sleep 30

kubectl -n postgres-operator port-forward svc/crunchy-grafana 3000 > pf3000.out &
echo '3000 port forwarded for Grafana. Access the Grafana dashboard.'
echo 'http://localhost:3000'

while :
do
    host=`kubectl -n postgres-operator get svc hasura -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`
    port=`kubectl -n postgres-operator get svc hasura -o jsonpath='{.spec.ports[0].port}'`
    STATUS=`kubectl -n $name describe postgresclusters.postgres-operator.crunchydata.com hippo`
    if [ "$STATUS" != "" ]; then
        echo "Created for hasura Container!!"
        break
    else
        echo "Wait for hasura Creating."
        sleep 3
    fi
done

while :
do
    STATUS=`curl http://$host:$port/console`
    if [ "$STATUS" != "" ]; then
        echo "access to hasura graphql"
        break
    else
        echo "Wait for hasura consle."
        sleep 3
    fi
done

echo http://$host:$port/console