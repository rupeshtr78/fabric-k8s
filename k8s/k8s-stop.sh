kubectl delete -f 7org1-cli-deploy.yaml
kubectl delete -f 6docker-volume.yaml
kubectl delete -f 5docker.yaml
kubectl delete -f 4peer0-org1-deploy.yaml
kubectl delete -f 3orderer0-orgorderer1-deploy.yaml
kubectl delete -f 2pv-pvc.yaml
kubectl delete -f 1namespace.yaml
echo "End"