pipeline {
    options {
        timestamps()
        skipDefaultCheckout()
    }
    agent {
        node { label 'build && aws && linux'}
    }
    parameters {
        string(name: 'BUILD_VERSION', defaultValue: '', description: 'The build version to deploy (optional)')
    }
    triggers {
        pollSCM('H/5 * * * *')
    }
    environment {
        PROJECT_NAME = "intlim"
    }
    stages {
        stage('Build Version') {
            when {
                expression {
                    return !params.BUILD_VERSION
                }
            }
            steps{
                script {
                    BUILD_VERSION_GENERATED = VersionNumber(
                        versionNumberString: 'v${BUILD_YEAR, XX}.${BUILD_MONTH, XX}${BUILD_DAY, XX}.${BUILDS_TODAY}',
                        projectStartDate:    '1970-01-01',
                        skipFailedBuilds:    true)
                    currentBuild.displayName = BUILD_VERSION_GENERATED
                    env.BUILD_VERSION = BUILD_VERSION_GENERATED
                    env.BUILD = 'true'
                }
            }
        }
        stage('Build') {
            when {
                expression {
                    return !params.BUILD_VERSION
                }
            }
            steps {
                sshagent (credentials: ['871f96b5-9d34-449d-b6c3-3a04bbd4c0e4']) {
                    withEnv([
                        "IMAGE_NAME=intlim",
                        "BUILD_VERSION=" + (params.BUILD_VERSION ?: env.BUILD_VERSION)
                    ]) {
                        checkout scm
                        sh  """  
                            docker pull rocker/shiny:4.1.0
                        """
                        script {
                           def image = docker.build(
                                "ncats/intlim:${env.BUILD_VERSION}",
                                "--no-cache ."
                            )
                            
                            docker.withRegistry('https://853771734544.dkr.ecr.us-east-1.amazonaws.com', 'ecr:us-east-1:ifx-jenkins-ci') {
                                image.push("${env.BUILD_VERSION}")
                            }
                        }
                    }
                }
            }
        }
        stage('Deploy Application') {
            agent {
                node { label 'intlim.ncats.io'}
            }
            steps {
                cleanWs()
                configFileProvider([
                    configFile(fileId: 'intlim-docker-compose.yml', targetLocation: 'docker-compose.yml')
                ]) {	
                    withAWS(credentials:'ifx-jenkins-ci') {
                        sh '''
                            export DOCKER_LOGIN="`aws ecr get-login --no-include-email --region us-east-1`"
                            $DOCKER_LOGIN
                           '''
                           ecrLogin()
                        script {
                            def docker = new org.labshare.Docker()
                            docker.deployDockerUI()
                        }
                    }
                }
            }
        }
    }
}
