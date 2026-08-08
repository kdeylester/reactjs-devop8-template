pipeline {
    agent any

     tools{
        nodejs 'NodeJsV20'
    }

     environment{
        TAG="v1.0.${env.BUILD_NUMBER}" // built-in
        IMG_NAME="reactjs-app"
        DH_USER="kdzy168"

        FULL_IMG="${DH_USER}/${IMG_NAME}:${TAG}"
    }


    stages {
        stage('Git Checkout') {
            steps {
                git 'https://github.com/kdeylester/reactjs-devop8-template.git'
            }
        }

        stage('Run Test Application') {
            steps {
                sh """
                npm i # install dependencies 
                # run test 
                npm run test 
                """
                }
        }

        
        stage('Build Application') {
            steps {
                sh "docker build -t reactjs-app -f prod.Dockerfile ."
                }
        }

        stage('Push Image To Docker Hub'){
            steps{
                withCredentials([usernamePassword(credentialsId: 'DockerLogin', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                // some block
                sh """ 
                    echo "${PASSWORD}" | docker login -u ${USERNAME} --password-stdin
                    docker tag reactjs-app ${FULL_IMG}
                    docker push "${FULL_IMG}"
                """
                }
            }
        }

        stage('Deploy Application') {
            steps {
                sh """ 
                    docker stop reactjs-app || true 
                    docker rm reactjs-app || true 
                    docker run -dp 3000:80 --name reactjs-app ${FULL_IMG} 
                """
            }
        }
        
        stage('Configure Domain') {
            steps {
                sh '''
                    # it need to check if domain already exist or not
                     sudo setup-domain.sh myweb 3000
                '''
            }
        }

    }
}
