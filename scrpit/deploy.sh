#!/bin/bash

# 설정 변수
REMOTE_USER="ubuntu"                 # 원격 서버 사용자 이름
REMOTE_HOST="13.209.75.109"          # 원격 서버 IP 주소
REMOTE_DIR="myweb"     # 원격 서버의 JAR 파일을 저장할 디렉토리
JAR_FILE="myweb-0.0.1-SNAPSHOT.jar"      # 로컬에서 빌드한 JAR 파일 이름
SSH_KEY="secrets/sunaweb_key.pem"

# 1. 프로젝트 루트 디렉토리로 이동
cd ..
export JAVA_HOME=$(/usr/libexec/java_home -v 17)


# 2. 로컬에서 JAR 파일 빌드 (Gradle Wrapper 사용)
echo "빌드 중..."
chmod +x gradlew                     # gradlew 파일에 실행 권한 부여
./gradlew clean build -x test        # Gradle을 사용하여 빌드

 # 2. 원격 서버로 JAR 파일 전송
echo "파일 전송 중..."
scp -i ${SSH_KEY} build/libs/${JAR_FILE} ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}

 # 3. 원격 서버에서 JAR 파일 실행
 echo "원격 서버에서 애플리케이션 실행 중..."
 ssh -i ${SSH_KEY}  ${REMOTE_USER}@${REMOTE_HOST} << EOF
 # 원격 서버에서 실행 중인 애플리케이션 중지 (옵션)
 pkill -f ${JAR_FILE}

 # JAR 파일 실행
 nohup java -jar -Dspring.profiles.active=dev ${REMOTE_DIR}/${JAR_FILE} > ${REMOTE_DIR}/app.log 2>&1 &

 # 애플리케이션 실행 확인
 sleep 5
 if pgrep -f ${JAR_FILE} > /dev/null
 then
   echo "애플리케이션이 성공적으로 시작되었습니다."
 else
   echo "애플리케이션 시작에 실패했습니다."
 fi
EOF

 echo "배포 완료."