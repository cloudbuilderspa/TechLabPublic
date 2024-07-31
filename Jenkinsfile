pipeline { //pipeline
  environment { //env init
    AWS_DEFAULT_REGION='us-east-1'
    tf_args = ""
    all_action = ""
    BRANCH_NAME = "develop"
    LAST_STAGE_NAME = ""
    ENVIRONMENT = ""
    VERSION_HASH = ""
    APP_NAME = "techlab"
    API_NAME = "backend-api"
    FRONT_NAME = "frontend"
    INFRAESTRUCTURE="infraestructure"
    jenkinsfileStagesApi = null
    jenkinsfileStagesFront = null
    jenkinsfileStagesInfraestructure = null

    checksumHashApi = ""
    checksumHashFront = ""
    checksumHashInfraestructure = ""
} //env end

  tools { terraform "terraform-v1.1.4"}
  
  agent {label 'macos-slave'}

    parameters {
      choice(
          name: 'ACTION',
          choices: ['', 'plan', 'apply', 'destroy', 'show', 'output', 'import', 'state', 'shell'],
          description: 'Opciones de ejecución sobre la infraestructura de un ambiente en particular'
      )
      choice(
          name: 'RESOURCE_PATH',
          choices: ['dynamoDB','endpoints','bucket','cluster-aurora', 'proxy-aurora', 'rds','waf', 'tf-state', 'tf-state-cluster', 'tf-state-proxy', 'tf-state-waf','vpc'],
          description: 'Path del recurso al que se le aplicará la acción'
      )
    } //parameters end

    stages { //stages init

    stage("Checkout") {
      steps {
        script {
          BRANCH_NAME = "${env.GIT_BRANCH}"
          echo "Current BRANCH_NAME: ${BRANCH_NAME}"
          if (params.GIT_BRANCH_NAME != null &&
            !params.GIT_BRANCH_NAME.trim().isEmpty() &&
            !params.GIT_BRANCH_NAME.trim().equals("default")) {
            BRANCH_NAME = "${params.GIT_BRANCH_NAME}".trim()
            BRANCH_NAME = BRANCH_NAME.replace("origin/","")
            echo "BRANCH_NAME: ${BRANCH_NAME}, GIT_URL: ${env.GIT_URL}"
            git branch: BRANCH_NAME, credentialsId: 'git', url: env.GIT_URL
          } else{
            BRANCH_NAME = BRANCH_NAME.replace("origin/","")
            echo "BRANCH_NAME: ${BRANCH_NAME}, GIT_URL: ${env.GIT_URL}"
          }
        }
      }
    }

    stage("Config") {
      steps {
        script {

          LAST_STAGE_NAME = env.STAGE_NAME
          ENVIRONMENT = getEnvironment()
        
          println("ENVIRONMENT: ${ENVIRONMENT}")

          if (JOB_URL.contains("jenmprod")) {
            if (BRANCH_NAME.contains("feature/")) {
              currentBuild.result = "ABORTED"
              error("Ramas feature/* no pueden ejecutarse en Jenkins de certificacion / pre-produccion / produccion")
            }
            if (BRANCH_NAME.contains("develop") && !JOB_URL.contains("job/certificacion")) {
              currentBuild.result = "ABORTED"
              error("Ramas develop no pueden ejecutarse en Jenkins de pre-produccion / produccion")
            }
          }
          jenkinsfileStagesInfraestructure = loadJenkinStages(ENVIRONMENT, INFRAESTRUCTURE)
        }
      }
    }
    // stage('CHMOD'){
    // steps{
    //   script{
    //     dir(infraestructure){
    //     sh 'chmod +x tf-apply.sh'
    //     sh 'chmod +x tf-plan.sh'
    //     }
    //   }
    // }
    // }

      // stage('DB AWS ENV') {
      //   steps{
      //     script {
      //       def folder = INFRAESTRUCTURE +"/"+ ENVIRONMENT +"/rds"
      //       dir(folder) {
      //       def sufix = ENVIRONMENT == 'qa' ? 'cert' : ENVIRONMENT;
      //       println("sufix: ${sufix}")
      //       def techlab_DB_USER = getCredentialUsernamePassword("techlab_db_${sufix}").username
      //       def techlab_DB_SECRET = getCredentialUsernamePassword("techlab_db_${sufix}").password
      //       sh """sed -i "s|ky|${techlab_DB_SECRET}|g" rds-postgresql.tf"""
      //       }
      //     }
      //   }
      // }

      stage("Terraform Plan") {
        when {
          expression {
            return (params.ACTION == 'plan' && jenkinsfileStagesInfraestructure != null)
          }
        }
        steps {
            script {
              LAST_STAGE_NAME = env.STAGE_NAME
              dir(jenkinsfileStagesInfraestructure.getFolderName()) {
                def sufix = ENVIRONMENT == 'qa' ? 'cert' : ENVIRONMENT;
                withAWS(credentials: "techlab_aws_${sufix}", region: "${AWS_DEFAULT_REGION}") {
                jenkinsfileStagesInfraestructure.terraformPlan(ENVIRONMENT)
                }
              } //dir end
          } //script end

      } //steps TF Apply - TF Destroy end
    } //stage TF Apply - TF Destroy end



      stage("Terraform Apply|Destroy") {
        when {
          expression {
            return (params.ACTION == 'apply' || params.ACTION == 'destroy')
          }
        }
        steps {
            script {
              dir(jenkinsfileStagesInfraestructure.getFolderName()) {
                def sufix = ENVIRONMENT == 'qa' ? 'cert' : ENVIRONMENT;
                withAWS(credentials: "  }", region: "${AWS_DEFAULT_REGION}") {
                jenkinsfileStagesInfraestructure.terraformApply(ENVIRONMENT)
                }              
              } //dir end
          } //script end
      } //steps TF Apply - TF Destroy end
    } //stage TF Apply - TF Destroy end


      stage("No Action") { // Stage No Action init
        when {
          expression {
            return !params.ACTION?.trim()
          }
        }
        steps {
          script {
            currentBuild.displayName = "No Action"
            echo "No se definio ACTION o ENVIRONMENT"
          }
        }
      }//stage no action end

      stage('get_commit_details') {
        steps {
            script {
                env.GIT_COMMIT_MSG = sh (script: 'git log -1 --pretty=%B ${GIT_COMMIT}', returnStdout: true).trim()
                env.GIT_AUTHOR = sh (script: 'git log -1 --pretty=%cn ${GIT_COMMIT}', returnStdout: true).trim()
            }
        }
    }
    }//stages end

} //pipeline end




def getEnvironment() {
  def isJenkinsQa = env.JOB_URL.contains("/job/certificacion/")
  def isJenkinsProd = env.JOB_URL.contains("/job/produccion/")
  if (isJenkinsQa) {
    return "qa"
  } else if (isJenkinsProd) {
    if (BRANCH_NAME.contains("master") || BRANCH_NAME.contains("release/delivery")) {
      return "prod"
    } else {
      return "staging"
    }
  } else {
    return "dev"
  }
}



def loadJenkinStages(environment, name) {
  // se cargan los stages de infraestructure
  def jenkinsfileStages = null
  try {
    println("Cargando archivo: ${name}/Jenkinsfile.stages")
    jenkinsfileStages = load "${name}/Jenkinsfile.stages"
  } catch(Exception ex) {
    println(ex)
    jenkinsfileStages = null
  }
  return jenkinsfileStages
}



def getCredentialAws(String credentialsId) {
  def map = [
    accessKey: "",
    secretKey: ""
  ]
  withCredentials([[
    $class: 'AmazonWebServicesCredentialsBinding',
    credentialsId: credentialsId, accessKeyVariable: 'accessKeyVariableValue', secretKeyVariable: 'secretKeyVariableValue'
  ]]) {
    map.accessKey = accessKeyVariableValue
    map.secretKey = secretKeyVariableValue
  }
  return map
}




def getCredentialUsernamePassword(String credentialsId) {
  def map = [
    username: "",
    password: ""
  ]
  withCredentials([usernamePassword(credentialsId: credentialsId, usernameVariable: 'usernameValue', passwordVariable: 'passwordValue')]) {
    map.username = usernameValue
    map.password = passwordValue
  }
  return map
}
