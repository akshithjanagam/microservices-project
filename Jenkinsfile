
pipeline {
    agent any

    stages {
        stage('Deploy To Kubernetes') {
            steps {
                withCredentials([
                    file(credentialsId: 'kubeconfig-file-new',
                         variable: 'KUBECONFIG')
                ]) {
                    sh '''
                        set -e
                        kubectl apply -f deployment-service.yml -n webapps
                    '''
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                withCredentials([
                    file(credentialsId: 'kubeconfig-file-new',
                         variable: 'KUBECONFIG')
                ]) {
                    sh '''
                        set -e
                        kubectl get deployments -n webapps
                        kubectl get pods -n webapps
                        kubectl get svc -n webapps
                    '''
                }
            }
        }
    }
}
