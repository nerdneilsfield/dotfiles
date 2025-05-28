export GROOVY_HOME=/usr/local/opt/groovy/libexec


[ -s "$JABBA_HOME/jabba.sh" ] && source "$JABBA_HOME/jabba.sh"


# @brief Add Azul Zulu OpenJDK PPA repository
# @return 0 on success
# @example add_zulu_ppa
# @category java
add_zulu_ppa(){
   sudo apt install -y gnupg ca-certificates curl software-properties-common
   curl -s https://repos.azul.com/azul-repo.key | sudo gpg --dearmor -o /usr/share/keyrings/azul.gpg 
   echo "deb [signed-by=/usr/share/keyrings/azul.gpg] https://repos.azul.com/zulu/deb stable main" | sudo tee /etc/apt/sources.list.d/zulu.list
   sudo apt update
}

# @brief Install Azul Zulu OpenJDK
# @param $1 JDK version (default: 21)
# @return 0 on success
# @example install_zulu_jdk 17
# @category java
install_zulu_jdk() {
    local _jdk_version
    if [ $# -eq 0 ]; then
        _jdk_version=21
    else
        _jdk_version=$1
    fi

    sudo apt install -y "zulu${_jdk_version}-jdk"
}

# @brief Display Maven configuration for Chinese mirrors
# @return 0 on success
# @example set_maven_mirror_cn
# @category java
set_maven_mirror_cn(){
    echo  """ 修改 ~/.m2/settings.xml 
<mirrors>
    <mirror>
     <id>aliyunmaven</id>
     <mirrorOf>central</mirrorOf>
     <name>阿里云公共仓库</name>
     <url>https://maven.aliyun.com/repository/central</url>
    </mirror>
    <mirror>
      <id>repo1</id>
      <mirrorOf>central</mirrorOf>
      <name>central repo</name>
      <url>http://repo1.maven.org/maven2/</url>
    </mirror>
    <mirror>
     <id>aliyunmaven</id>
     <mirrorOf>apache snapshots</mirrorOf>
     <name>阿里云阿帕奇仓库</name>
     <url>https://maven.aliyun.com/repository/apache-snapshots</url>
    </mirror>
  </mirrors>
"""
}