##Proyecto de Ejemplo Spring-boot pipelines
oc new-project dev-admin-users --display-name "dev-admin-users"

#Adicionar permisos al service-account del namespace de Jenkins
oc policy add-role-to-user edit system:serviceaccount:jenkins-shared:jenkins -n dev-admin-users

#Crear BuildConfig de tipo binario y referenciando la imagen bade de Java
oc new-build --binary=true --name="api-users" openshift/java:8  -n dev-admin-users

#Crear el DeploymentConfig
oc new-app dev-admin-users/api-users:latest --name=api-users --allow-missing-imagestream-tags=true -n dev-admin-users

#De manera opcional se pueden configurar los Limites de recursos para la aplicación
oc set resources dc api-users --limits=memory=800Mi,cpu=1000m --requests=memory=600Mi,cpu=500m

#Desactivar triggers en la app para evitar el build y el deploy  automatico (Se quiere que el proceso lo controle jenkins)
oc set triggers dc/api-users --remove-all -n dev-admin-users

#Creación del configmap
oc create configmap myconfigmap

#Asociación del config map al DeploymentConfig
oc set volume dc/api-users --add --name=map-application --mount-path=/deployments/config/application.properties --sub-path=application.properties --configmap-name=myconfigmap

#Crear el service a partir del deploymentConfig, en este caso el puerto 8080
oc expose dc api-users --port 8080 -n dev-admin-users

#Crear el route a partir del servicio
oc expose svc api-users -n dev-admin-users

#Configurar Health-check
oc set probe dc/api-users -n dev-admin-users --readiness --failure-threshold 3 --initial-delay-seconds 20 --get-url=http://:8080/healthcheck
