// ─────────────────────────────────────────────────────────────────────────────
//  Jenkinsfile — Jenkins CI/CD Pipeline
//  Project : Static HTML/Nginx App
//  Pipeline : Checkout → Test → Build Docker Image → Verify → Cleanup
// ─────────────────────────────────────────────────────────────────────────────

pipeline {

    // Run on any available Jenkins agent
    agent any

    // ── Environment variables ───────────────────────────────────────────────
    environment {
        APP_NAME    = 'nginx-portfolio-app'
        DOCKER_USER = 'uhani3824'
        IMAGE_NAME  = "${DOCKER_USER}/${APP_NAME}"
        IMAGE_TAG   = "${BUILD_NUMBER}"                  // unique tag per build
        FULL_IMAGE  = "${IMAGE_NAME}:${IMAGE_TAG}"
        CONTAINER_TEST_NAME = "test-${APP_NAME}-${BUILD_NUMBER}"
    }

    // ── Build triggers ──────────────────────────────────────────────────────
    triggers {
        // Poll GitHub every 5 minutes for new commits
        // Replace with GitHub webhook in production
        pollSCM('H/5 * * * *')
    }

    // ── Pipeline stages ─────────────────────────────────────────────────────
    stages {

        // ── Stage 1: Checkout ───────────────────────────────────────────────
        stage('Checkout') {
            steps {
                echo "===== Stage 1: Checkout ====="
                echo "Branch   : ${env.BRANCH_NAME ?: 'main'}"
                echo "Build #  : ${BUILD_NUMBER}"
                echo "Job      : ${JOB_NAME}"
                echo "Workspace: ${WORKSPACE}"

                // List files to confirm repo was cloned correctly
                sh 'ls -la'
            }
        }

        // ── Stage 2: Test ───────────────────────────────────────────────────
        stage('Test') {
            steps {
                echo "===== Stage 2: Test ====="

                // Make test script executable
                sh 'chmod +x tests/test_html.sh'

                // Run the HTML validation tests
                sh './tests/test_html.sh'
            }
        }

        // ── Stage 3: Build Docker Image ─────────────────────────────────────
        stage('Build Docker Image') {
            steps {
                echo "===== Stage 3: Build Docker Image ====="
                echo "Building image: ${FULL_IMAGE}"

                // Build the Docker image from our Dockerfile
                sh 'docker build -t ${FULL_IMAGE} .'

                // Also tag it as latest
                sh 'docker tag ${FULL_IMAGE} ${IMAGE_NAME}:latest'

                echo "Image built successfully: ${FULL_IMAGE}"
            }
        }

	// ── Stage 4: Verify Image ───────────────────────────────────────────
        stage('Verify Image') {
            steps {
                echo "===== Stage 4: Verify Image ====="

                // Confirm the image exists in local Docker
                sh 'docker images ${IMAGE_NAME}'

                // Run container and verify via its internal IP
                sh '''
                    echo "Starting test container..."
                    docker run -d \
                        --name ${CONTAINER_TEST_NAME} \
                        ${FULL_IMAGE}

                    echo "Waiting for container to start..."
                    sleep 5

                    echo "Getting container IP..."
                    CONTAINER_IP=$(docker inspect --format="{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}" ${CONTAINER_TEST_NAME})
                    echo "Container IP: $CONTAINER_IP"

                    echo "Checking health endpoint..."
                    curl -f http://$CONTAINER_IP/health && echo " Health check PASSED ✅"
                '''
            }
        }
        
        // ── Stage 5: Push to Docker Hub (only on main branch) ───────────────
        stage('Push to Docker Hub') {
            when {
                // Only push when building the main branch
                anyOf {
                    branch 'main'
                    expression { return env.BRANCH_NAME == null }
                }
            }
            steps {
                echo "===== Stage 5: Push to Docker Hub ====="

                // Use credentials stored in Jenkins — never hardcode passwords!
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DH_USER',
                    passwordVariable: 'DH_PASS'
                )]) {
                    sh '''
                        echo "Logging in to Docker Hub..."
                        echo $DH_PASS | docker login -u $DH_USER --password-stdin

                        echo "Pushing ${FULL_IMAGE}..."
                        docker push ${FULL_IMAGE}

                        echo "Pushing latest tag..."
                        docker push ${IMAGE_NAME}:latest

                        echo "Push complete ✅"
                    '''
                }
            }
        }
    }

    // ── Post-build actions ──────────────────────────────────────────────────
    post {

        always {
            echo "===== Cleanup ====="

            // Stop and remove the test container
            sh '''
                docker stop ${CONTAINER_TEST_NAME} || true
                docker rm   ${CONTAINER_TEST_NAME} || true
            '''

            // Remove the built image to save disk space
            sh '''
                docker rmi ${FULL_IMAGE}        || true
                docker rmi ${IMAGE_NAME}:latest || true
                docker logout                   || true
            '''

            echo "Cleanup done."
        }

        success {
            echo """
╔══════════════════════════════════════╗
║   ✅  BUILD #${BUILD_NUMBER} PASSED   ║
║   Image: ${FULL_IMAGE}
╚══════════════════════════════════════╝
            """
        }

        failure {
            echo """
╔══════════════════════════════════════╗
║   ❌  BUILD #${BUILD_NUMBER} FAILED   ║
║   Check console output above         ║
╚══════════════════════════════════════╝
            """
        }
    }
}
