#!/usr/bin/env bash
# _modules/scripts/core.sh
# THIS SCRIPT IS DESIGNED TO BE RUNNING BY MAILCOW SCRIPTS ONLY!
# DO NOT, AGAIN, NOT TRY TO RUN THIS SCRIPT STANDALONE!!!!!!

# ANSI color for red errors
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
MAGENTA='\e[35m'
LIGHT_RED='\e[91m'
LIGHT_GREEN='\e[92m'
NC='\e[0m'

caller="${BASH_SOURCE[1]##*/}"

install_docker() {
    echo -e "${YELLOW}Docker is not installed. Installing Docker...${NC}"
    echo -e "${YELLOW}Docker غير مثبت. جارٍ تثبيت Docker...${NC}"

    # Install prerequisites
    if command -v apt-get &>/dev/null; then
        apt-get update -qq
        apt-get install -y -qq curl ca-certificates gnupg lsb-release
    elif command -v yum &>/dev/null; then
        yum install -y -q curl ca-certificates
    elif command -v dnf &>/dev/null; then
        dnf install -y -q curl ca-certificates
    fi

    # Install Docker using official script
    echo -e "${YELLOW}Running official Docker installation script...${NC}"
    echo -e "${YELLOW}جارٍ تشغيل سكربت تثبيت Docker الرسمي...${NC}"
    curl -fsSL https://get.docker.com | sh

    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Failed to install Docker. Please install manually.${NC}"
        echo -e "${RED}فشل تثبيت Docker. يرجى التثبيت يدوياً.${NC}"
        exit 1
    fi

    # Start and enable Docker service
    if command -v systemctl &>/dev/null; then
        systemctl start docker
        systemctl enable docker
    fi

    echo -e "${GREEN}Docker installed successfully!${NC}"
    echo -e "${GREEN}تم تثبيت Docker بنجاح!${NC}"
}

install_prerequisites() {
    local missing_tools=("$@")
    echo -e "${YELLOW}Installing missing prerequisites: ${missing_tools[*]}${NC}"
    echo -e "${YELLOW}جارٍ تثبيت المتطلبات المفقودة: ${missing_tools[*]}${NC}"

    if command -v apt-get &>/dev/null; then
        apt-get update -qq
        for tool in "${missing_tools[@]}"; do
            case $tool in
                sha1sum) apt-get install -y -qq coreutils ;;
                *) apt-get install -y -qq "$tool" ;;
            esac
        done
    elif command -v yum &>/dev/null; then
        for tool in "${missing_tools[@]}"; do
            case $tool in
                sha1sum) yum install -y -q coreutils ;;
                *) yum install -y -q "$tool" ;;
            esac
        done
    elif command -v dnf &>/dev/null; then
        for tool in "${missing_tools[@]}"; do
            case $tool in
                sha1sum) dnf install -y -q coreutils ;;
                *) dnf install -y -q "$tool" ;;
            esac
        done
    else
        echo -e "${RED}Cannot detect package manager. Please install manually: ${missing_tools[*]}${NC}"
        echo -e "${RED}تعذر اكتشاف مدير الحزم. يرجى التثبيت يدوياً: ${missing_tools[*]}${NC}"
        exit 1
    fi
}

get_installed_tools(){
    local missing_tools=()

    for bin in openssl curl docker git awk sha1sum grep cut jq; do
        if [[ -z $(command -v ${bin}) ]]; then
            missing_tools+=("$bin")
        fi
    done

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        echo -e "${YELLOW}Missing tools detected: ${missing_tools[*]}${NC}"
        echo -e "${YELLOW}تم اكتشاف أدوات مفقودة: ${missing_tools[*]}${NC}"

        # Check if docker is among missing tools
        if [[ " ${missing_tools[*]} " =~ " docker " ]]; then
            install_docker
            # Remove docker from missing_tools array
            missing_tools=("${missing_tools[@]/docker}")
        fi

        # Install other missing tools
        local other_missing=()
        for tool in "${missing_tools[@]}"; do
            [[ -n "$tool" ]] && other_missing+=("$tool")
        done

        if [[ ${#other_missing[@]} -gt 0 ]]; then
            install_prerequisites "${other_missing[@]}"
        fi

        # Verify all tools are now installed
        for bin in openssl curl docker git awk sha1sum grep cut jq; do
            if [[ -z $(command -v ${bin}) ]]; then
                echo -e "${RED}Error: Failed to install '${bin}'. Cannot proceed.${NC}"
                echo -e "${RED}خطأ: فشل تثبيت '${bin}'. لا يمكن المتابعة.${NC}"
                exit 1
            fi
        done

        echo -e "${GREEN}All prerequisites installed successfully!${NC}"
        echo -e "${GREEN}تم تثبيت جميع المتطلبات بنجاح!${NC}"
    fi

    if grep --help 2>&1 | head -n 1 | grep -q -i "busybox"; then echo -e "${LIGHT_RED}BusyBox grep detected, please install gnu grep, \"apk add --no-cache --upgrade grep\"${NC}"; exit 1; fi
    # This will also cover sort
    if cp --help 2>&1 | head -n 1 | grep -q -i "busybox"; then echo -e "${LIGHT_RED}BusyBox cp detected, please install coreutils, \"apk add --no-cache --upgrade coreutils\"${NC}"; exit 1; fi
    if sed --help 2>&1 | head -n 1 | grep -q -i "busybox"; then echo -e "${LIGHT_RED}BusyBox sed detected, please install gnu sed, \"apk add --no-cache --upgrade sed\"${NC}"; exit 1; fi
}

get_docker_version(){
    # Check Docker Version (need at least 24.X)
    docker_version=$(docker version --format '{{.Server.Version}}' | cut -d '.' -f 1)
}

get_compose_type(){
  if docker compose > /dev/null 2>&1; then
    if docker compose version --short | grep -e "^[2-9]\." -e "^v[2-9]\." -e "^[1-9][0-9]\." -e "^v[1-9][0-9]\." > /dev/null 2>&1; then
      COMPOSE_VERSION=native
      COMPOSE_COMMAND="docker compose"
      if [[ "$caller" == "update.sh" ]]; then
        sed -i 's/^DOCKER_COMPOSE_VERSION=.*/DOCKER_COMPOSE_VERSION=native/' "$SCRIPT_DIR/chertmail.conf"
      fi
      echo -e "\e[33mFound Docker Compose Plugin (native).\e[0m"
      echo -e "\e[33mتم العثور على إضافة Docker Compose (native).\e[0m"
      echo -e "\e[33mSetting the DOCKER_COMPOSE_VERSION Variable to native\e[0m"
      echo -e "\e[33mتعيين متغير DOCKER_COMPOSE_VERSION إلى native\e[0m"
      sleep 2
      echo -e "\e[33mNotice: You'll have to update this Compose Version via your Package Manager manually!\e[0m"
      echo -e "\e[33mملاحظة: ستحتاج لتحديث إصدار Compose عبر مدير الحزم يدوياً!\e[0m"
    else
      echo -e "\e[31mCannot find Docker Compose with a Version Higher than 2.X.X.\e[0m"
      echo -e "\e[31mلم يتم العثور على Docker Compose بإصدار أعلى من 2.X.X.\e[0m"
      echo -e "\e[31mPlease update/install it manually regarding to this doc site: https://docs.chertmail.com/install/\e[0m"
      echo -e "\e[31mيرجى تحديثه/تثبيته يدوياً وفقاً لهذه الوثائق: https://docs.chertmail.com/install/\e[0m"
      exit 1
    fi
  elif docker-compose > /dev/null 2>&1; then
  if ! [[ $(alias docker-compose 2> /dev/null) ]] ; then
    if docker-compose version --short | grep -e "^[2-9]\." -e "^[1-9][0-9]\." > /dev/null 2>&1; then
      COMPOSE_VERSION=standalone
      COMPOSE_COMMAND="docker-compose"
      if [[ "$caller" == "update.sh" ]]; then
        sed -i 's/^DOCKER_COMPOSE_VERSION=.*/DOCKER_COMPOSE_VERSION=standalone/' "$SCRIPT_DIR/chertmail.conf"
      fi
      echo -e "\e[33mFound Docker Compose Standalone.\e[0m"
      echo -e "\e[33mتم العثور على Docker Compose المستقل.\e[0m"
      echo -e "\e[33mSetting the DOCKER_COMPOSE_VERSION Variable to standalone\e[0m"
      echo -e "\e[33mتعيين متغير DOCKER_COMPOSE_VERSION إلى standalone\e[0m"
      sleep 2
      echo -e "\e[33mNotice: For an automatic update of docker-compose please use the update_compose.sh scripts located at the helper-scripts folder.\e[0m"
      echo -e "\e[33mملاحظة: للتحديث التلقائي لـ docker-compose يرجى استخدام سكربت update_compose.sh في مجلد helper-scripts.\e[0m"
    else
      echo -e "\e[31mCannot find Docker Compose with a Version Higher than 2.X.X.\e[0m"
      echo -e "\e[31mلم يتم العثور على Docker Compose بإصدار أعلى من 2.X.X.\e[0m"
      echo -e "\e[31mPlease update/install manually regarding to this doc site: https://docs.chertmail.com/install/\e[0m"
      echo -e "\e[31mيرجى تحديثه/تثبيته يدوياً وفقاً لهذه الوثائق: https://docs.chertmail.com/install/\e[0m"
      exit 1
    fi
  fi
  else
    echo -e "\e[31mCannot find Docker Compose.\e[0m"
    echo -e "\e[31mلم يتم العثور على Docker Compose.\e[0m"
    echo -e "\e[31mPlease install it regarding to this doc site: https://docs.chertmail.com/install/\e[0m"
    echo -e "\e[31mيرجى تثبيته وفقاً لهذه الوثائق: https://docs.chertmail.com/install/\e[0m"
    exit 1
  fi
}

detect_bad_asn() {
  echo -e "\e[33mDetecting if your IP is listed on Spamhaus Bad ASN List...\e[0m"
  echo -e "\e[33mجارٍ الكشف إذا كان عنوان IP الخاص بك مدرجاً في قائمة Spamhaus للـ ASN السيئة...\e[0m"
  response=$(curl --connect-timeout 15 --max-time 30 -s -o /dev/null -w "%{http_code}" "https://asn-check.mailcow.email")
  if [ "$response" -eq 503 ]; then
    if [ -z "$SPAMHAUS_DQS_KEY" ]; then
      echo -e "\e[33mYour server's public IP uses an AS that is blocked by Spamhaus to use their DNS public blocklists for Postfix.\e[0m"
      echo -e "\e[33mعنوان IP العام لخادمك يستخدم AS محظوراً من قبل Spamhaus لاستخدام قوائم الحظر العامة لـ Postfix.\e[0m"
      echo -e "\e[33mmailcow did not detected a value for the variable SPAMHAUS_DQS_KEY inside chertmail.conf!\e[0m"
      echo -e "\e[33mتشيرت ميل لم يكتشف قيمة للمتغير SPAMHAUS_DQS_KEY في chertmail.conf!\e[0m"
      sleep 2
      echo ""
      echo -e "\e[33mTo use the Spamhaus DNS Blocklists again, you will need to create a FREE account for their Data Query Service (DQS) at: https://www.spamhaus.com/free-trial/sign-up-for-a-free-data-query-service-account\e[0m"
      echo -e "\e[33mلاستخدام قوائم Spamhaus DNS مجدداً، ستحتاج إنشاء حساب مجاني لخدمة استعلام البيانات (DQS) على: https://www.spamhaus.com/free-trial/sign-up-for-a-free-data-query-service-account\e[0m"
      echo -e "\e[33mOnce done, enter your DQS API key in chertmail.conf and mailcow will do the rest for you!\e[0m"
      echo -e "\e[33mبعد الانتهاء، أدخل مفتاح DQS API في chertmail.conf وسيقوم تشيرت ميل بالباقي!\e[0m"
      echo ""
      sleep 2
    else
      echo -e "\e[33mYour server's public IP uses an AS that is blocked by Spamhaus to use their DNS public blocklists for Postfix.\e[0m"
      echo -e "\e[33mعنوان IP العام لخادمك يستخدم AS محظوراً من قبل Spamhaus لاستخدام قوائم الحظر العامة لـ Postfix.\e[0m"
      echo -e "\e[32mmailcow detected a Value for the variable SPAMHAUS_DQS_KEY inside chertmail.conf. Postfix will use DQS with the given API key...\e[0m"
      echo -e "\e[32mتشيرت ميل اكتشف قيمة للمتغير SPAMHAUS_DQS_KEY في chertmail.conf. سيستخدم Postfix DQS مع مفتاح API المعطى...\e[0m"
    fi
  elif [ "$response" -eq 200 ]; then
    echo -e "\e[33mCheck completed! Your IP is \e[32mclean\e[0m"
    echo -e "\e[33mاكتمل الفحص! عنوان IP الخاص بك \e[32mنظيف\e[0m"
  elif [ "$response" -eq 429 ]; then
    echo -e "\e[33mCheck completed! \e[31mYour IP seems to be rate limited on the ASN Check service... please try again later!\e[0m"
    echo -e "\e[33mاكتمل الفحص! \e[31mيبدو أن عنوان IP الخاص بك محدود المعدل على خدمة فحص ASN... يرجى المحاولة لاحقاً!\e[0m"
  else
    echo -e "\e[31mCheck failed! \e[0mMaybe a DNS or Network problem?\e[0m"
    echo -e "\e[31mفشل الفحص! \e[0mربما مشكلة DNS أو شبكة؟\e[0m"
  fi
}

check_online_status() {
  CHECK_ONLINE_DOMAINS=('https://github.com' 'https://hub.docker.com')
  for domain in "${CHECK_ONLINE_DOMAINS[@]}"; do
    if timeout 6 curl --head --silent --output /dev/null ${domain}; then
      return 0
    fi
  done
  return 1
}

prefetch_images() {
  [[ -z ${BRANCH} ]] && { echo -e "\e[33m\nUnknown branch...\e[0m"; echo -e "\e[33mفرع غير معروف...\e[0m"; exit 1; }
  git fetch origin #${BRANCH}
  while read image; do
    RET_C=0
    until docker pull "${image}"; do
      RET_C=$((RET_C + 1))
      echo -e "\e[33m\nError pulling $image, retrying...\e[0m"
      echo -e "\e[33mخطأ في سحب $image، جارٍ إعادة المحاولة...\e[0m"
      [ ${RET_C} -gt 3 ] && { echo -e "\e[31m\nToo many failed retries, exiting\e[0m"; echo -e "\e[31mمحاولات فاشلة كثيرة جداً، جارٍ الخروج\e[0m"; exit 1; }
      sleep 1
    done
  done < <(git show "origin/${BRANCH}:docker-compose.yml" | grep "image:" | awk '{ gsub("image:","", $3); print $2 }')
}

docker_garbage() {
  SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"
  IMGS_TO_DELETE=()

  declare -A IMAGES_INFO
  COMPOSE_IMAGES=($(grep -oP "image: \K(ghcr\.io/)?mailcow.+" "${SCRIPT_DIR}/docker-compose.yml"))

  for existing_image in $(docker images --format "{{.ID}}:{{.Repository}}:{{.Tag}}" | grep -E '(mailcow/|ghcr\.io/mailcow/)'); do
      ID=$(echo "$existing_image" | cut -d ':' -f 1)
      REPOSITORY=$(echo "$existing_image" | cut -d ':' -f 2)
      TAG=$(echo "$existing_image" | cut -d ':' -f 3)

      if [[ "$REPOSITORY" == "mailcow/backup" || "$REPOSITORY" == "ghcr.io/mailcow/backup" ]]; then
          if [[ "$TAG" != "<none>" ]]; then
              continue
          fi
      fi

      if [[ " ${COMPOSE_IMAGES[@]} " =~ " ${REPOSITORY}:${TAG} " ]]; then
          continue
      else
          IMGS_TO_DELETE+=("$ID")
          IMAGES_INFO["$ID"]="$REPOSITORY:$TAG"
      fi
  done

  if [[ ! -z ${IMGS_TO_DELETE[*]} ]]; then
      echo "The following unused mailcow images were found:"
      echo "تم العثور على الصور التالية غير المستخدمة من تشيرت ميل:"
      for id in "${IMGS_TO_DELETE[@]}"; do
          echo "    ${IMAGES_INFO[$id]} ($id)"
      done

      if [ -z "$FORCE" ]; then
          echo "Do you want to delete them to free up some space?"
          echo "هل تريد حذفها لتحرير بعض المساحة؟"
          read -r -p "[y/N] " response
          if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
              docker rmi ${IMGS_TO_DELETE[*]}
          else
              echo "OK, skipped."
              echo "حسناً، تم التخطي."
          fi
      else
          echo "Running in forced mode! Force removing old mailcow images..."
          echo "التشغيل في الوضع الإجباري! حذف صور تشيرت ميل القديمة إجبارياً..."
          docker rmi ${IMGS_TO_DELETE[*]}
      fi
      echo -e "\e[32mFurther cleanup...\e[0m"
      echo -e "\e[32mمزيد من التنظيف...\e[0m"
      echo "If you want to cleanup further garbage collected by Docker, please make sure all containers are up and running before cleaning your system by executing \"docker system prune\""
      echo "إذا كنت تريد تنظيف المزيد من الملفات المجمعة بواسطة Docker، تأكد من أن جميع الحاويات تعم�� قبل تنظيف نظامك بتنفيذ \"docker system prune\""
  fi
}

in_array() {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

detect_major_update() {
  if [ ${BRANCH} == "master" ]; then
    # Array with major versions
    # Add major versions here
    MAJOR_VERSIONS=(
      "2025-02"
      "2025-03"
      "2025-09"
    )

    current_version=""
    if [[ -f "${SCRIPT_DIR}/data/web/inc/app_info.inc.php" ]]; then
      current_version=$(grep 'MAILCOW_GIT_VERSION' ${SCRIPT_DIR}/data/web/inc/app_info.inc.php | sed -E 's/.*MAILCOW_GIT_VERSION="([^"]+)".*/\1/')
    fi
    if [[ -z "$current_version" ]]; then
      return 1
    fi
    release_url="https://github.com/mailcow/mailcow-dockerized/releases/tag"

    updates_to_apply=()

    for version in "${MAJOR_VERSIONS[@]}"; do
      if [[ "$current_version" < "$version" ]]; then
        updates_to_apply+=("$version")
      fi
    done

    if [[ ${#updates_to_apply[@]} -gt 0 ]]; then
      echo -e "\e[33m\nMAJOR UPDATES to be applied:\e[0m"
      echo -e "\e[33mتحديثات رئيسية سيتم تطبيقها:\e[0m"
      for update in "${updates_to_apply[@]}"; do
        echo "$update - $release_url/$update"
      done

      echo -e "\nPlease read the release notes before proceeding."
      echo -e "يرجى قراءة ملاحظات الإصدار قبل المتابعة."
      echo "Do you want to proceed with the update?"
      echo "هل تريد المتابعة مع التحديث؟"
      read -p "[y/n] " response
      if [[ "${response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        echo "Proceeding with the update..."
        echo "جارٍ المتابعة مع التحديث..."
      else
        echo "Update canceled. Exiting."
        echo "تم إلغاء التحديث. ��ارٍ الخروج."
        exit 1
      fi
    fi
  fi
}
