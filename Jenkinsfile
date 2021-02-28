pipeline
{
	agent any
		environment {
			KUBECONFIG = '/Users/sameerkataria/.kube/config'
		}
		tools
		{
			jdk 'JDK'
			maven 'maven'
		}
		options
	{
		timestamps()
		
		timeout(time: 1, unit: 'HOURS')
		
		skipDefaultCheckout()
		
		disableConcurrentBuilds()
	}
	
	stages
	{
			stage('Build')
			{
				steps
				{
					bat "mvn install"
				}
			}
			
			stage('Unit Testing')
			{
				steps
				{
					bat "mvn test"
				}
			}
			
			stage('Sonar Analysis')
			{
				steps
				{
					withSonarQubeEnv("Test_Sonar") {
						bat "mvn sonar:sonar"
					}
				}
			}
			
			stage('Upload to Artifactory')
			{
				steps
				{
					rtMavenDeployer(
						id: 'deployer',
						serverId: '123456789@artifactory',
						releaseRepo: 'CI-Automation-JAVA',
						snapshotRepo: 'CI-Automation-JAVA'
					)
					rtMavenRun(
						pom: 'pom.xml',
						goals: 'clean install',
						deployerId: 'deployer'
					)
					rtPublishBuildInfo(
						serverId: '123456789@artifactory'
					)
				}
			}
			
			stage('Docker Image')
			{
				steps
				{
					bat "docker build -t i_sameerkataria_master --no-cache -f Dockerfile ."
				}
			}
			
			stage('Push to DTR')
			{
				steps
				{
					bat "docker push dtr.nagarro.com:443/i_sameerkataria_master"
				}
			}
			
			stage('Stop Running Container')
			{
				steps
				{
					bat '''
					FOR /F "tokens=* USEBACKQ" %%F IN (`docker ps -qf name^=sameerkataria`) DO (
						SET ContainerID=%%F
					)
					IF NOT [%ContainerID%] == [] (
						echo "Stopping running container %ContainerID%"
						docker stop %ContainerID%
						docker rm -f %ContainerID%
					) ELSE ( echo "No existing container running")
				'''
				}
			}
			
			stage('Docker Deployment')
			{
				steps
				{
					bat "docker run --name c_sameerkataria_master -d -p 6200:8080 dtr.nagarro.com:443/i_sameerkataria_master"
				}
			}
			
			stage('Helm charts deployment')
			{
				steps
				{
					bat '''
					/kube/kubectl.exe create ns sameerkataria_nagp_%BUILD_NUMBER%
					/kube/helm.exe install mydevops-helm-nagp nagp-helm-chart -n sameerkataria_nagp_%BUILD_NUMBER%
				'''
				}
			}
	}
	
	post {
        always {
            junit 'target/surefire-reports/*.xml'
        }
    }
}
