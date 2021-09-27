FROM centos:7

ARG SONARQUBE_8.9.2-community

ENV \
  SONARQUBE_HOME="/opt/sonarqube" \
  SONARQUBE_8.9.2-community="${SONARQUBE_8.9.2-community}" \
  REPO_OFFICIAL="https://urldefense.com/v3/__https://binaries.sonarsource.com/Distribution__;!!IOGos0k!z75BPXvc_WSLoxP3xOSTSDxl0EcpoFuIbPZUdIOXkDrM0NmdlAjvfkmEV3gTwZzX9mSjtgfq$ " \
  SONARQUBE_UID="33333" \
  SONARQUBE_GID="23444" \
  http_proxy="https://urldefense.com/v3/__http://www-proxy.se/__;!!IOGos0k!z75BPXvc_WSLoxP3xOSTSDxl0EcpoFuIbPZUdIOXkDrM0NmdlAjvfkmEV3gTwZzX9iRTKeaa$ " \
  https_proxy="https://urldefense.com/v3/__https://www-proxy.se/__;!!IOGos0k!z75BPXvc_WSLoxP3xOSTSDxl0EcpoFuIbPZUdIOXkDrM0NmdlAjvfkmEV3gTwZzX9pGEBlJK$ "

RUN set -x \
  \
  && yum update -y \
  && yum install -y \
  java-11-openjdk \
  unzip \
  wget \
  \
  && groupadd --gid "${SONARQUBE_GID}" --system sonarqube \
  && useradd --uid "${SONARQUBE_UID}" --gid "${SONARQUBE_GID}" --system --home "${SONARQUBE_HOME}" --shell /bin/bash sonarqube \
  \
  && cd /opt \
  && curl -o sonarqube.zip -fSL "${REPO_OFFICIAL}"/sonarqube/sonarqube-"${SONARQUBE_8.9.2-community}".zip \
  && curl -o sonarqube.zip.asc -fSL "${REPO_OFFICIAL}"/sonarqube/sonarqube-"${SONARQUBE_8.9.2-community}".zip.asc \
  && unzip sonarqube.zip \
  && mv sonarqube-"${SONARQUBE_8.9.2-community}" sonarqube \
  && rm sonarqube.zip* \
  && rm "${SONARQUBE_HOME}"/data/README.txt \
  && rm "${SONARQUBE_HOME}"/conf/wrapper.conf \
  && rmdir "${SONARQUBE_HOME}"/data \
  && rm -rf "${SONARQUBE_HOME}"/bin/* \
  \
  && chown -R "${SONARQUBE_UID}":"${SONARQUBE_GID}" "${SONARQUBE_HOME}" \
  \
  && yum remove -y unzip \
  && yum clean all \
  && rm -rf /var/cache/yum \
  ;

COPY EGADRootCA /etc/ssl/certs/

EXPOSE 9000 9001 9002 

# VOLUME syntax is fragile
# do not add commas after each volume
# do not remove space before end-of-line backslash \
# volumes are required to run a read-only container
VOLUME \
  "/sqdata" \
  "${SONARQUBE_HOME}/extensions/plugins" \
  "${SONARQUBE_HOME}/logs" \
  "${SONARQUBE_HOME}/temp" \
  "${SONARQUBE_HOME}/web" \
  "/tmp"

# data
# - elasticsearch data is stored in /sqdata/es
# - compute engine data is stored in /sqdata/ce
# - plugins web data is stored in /sqdata/web

# extensions
# - custom coding rules are stored in extensions/rules
# - plugins are stored in extensions/plugins

ENV \
  EXT_DL="/opt/sonarqube/extensions/downloads" \
  # official plugins
  PLUG_CSHARP_VER="8.6.1.17183" \
  PLUG_GO_VER="1.6.0.719" \
  PLUG_HTML_VER="3.2.0.2082" \
  PLUG_JACOCO_VER="1.1.0.898" \
  PLUG_JAVA_VER="6.3.2.22818" \
  PLUG_JAVASCRIPT_VER="6.2.1.12157" \
  PLUG_KOTLIN_VER="1.5.0.315" \
  PLUG_LDAP_VER="2.2.0.608" \
  PLUG_PHP_VER="3.3.0.5166" \
  PLUG_PYTHON_VER="2.8.0.6204" \
  PLUG_SCM_GIT_VER="1.11.0.11" \
  PLUG_SCM_SVN_VER="1.9.0.1295" \
  PLUG_SONARSCALA_VER="1.5.0.315" \
  PLUG_TYPESCRIPT_VER="2.1.0.4359" \
  PLUG_XML_VER="2.0.1.2020" \
  PLUG_CSS_VER="1.2.0.1325" \
  PLUG_RUBY_VER="1.5.0.315" \
  PLUG_VBNET="8.6.0.16497" \
  # community plugins
  PLUG_BRANCH_VER="1.3.2" \
  PLUG_ANSIBLE_VER="2.3.0" \
  PLUG_CHECKSTYLE_VER="8.35" \
  PLUG_COBERTURA_VER="2.0" \
  PLUG_FINDBUGS_VER="3.11.1" \
  PLUG_GROOVY_VER="1.6" \
  PLUG_SHELLCHECK_VER="2.3.0" \
  PLUG_PMD_VER="3.2.1" \ 
  PLUG_YAML_VER="1.5.1" \
  PLUG_JAZZ_VER="1.2" \
  PLUG_CXX_VER="1.3.2" \
  PLUG_PERL_VER="0.4.6" \
  PLUG_CLOJURE_VER="2.0.0"

RUN set -x \
  \
  && mkdir -p "${EXT_DL}" \
  \
  && wget --retry-connrefused -O "${EXT_DL}"/sonar-csharp-plugin-"${PLUG_CSHARP_VER}".jar \
  "${REPO_OFFICIAL}"/sonar-csharp-plugin/sonar-csharp-plugin-"${PLUG_CSHARP_VER}".jar \
  \
  && wget --retry-connrefused -O "${EXT_DL}"/sonar-go-plugin-"${PLUG_GO_VER}".jar \
  "${REPO_OFFICIAL}"/sonar-go-plugin/sonar-go-plugin-"${PLUG_GO_VER}".jar \
  \
  && wget --retry-connrefused -O "${EXT_DL}"/sonar-html-plugin-"${PLUG_HTML_VER}".jar \
  "${REPO_OFFICIAL}"/sonar-html-plugin/sonar-html-plugin-"${PLUG_HTML_VER}".jar \
  \
  && wget --retry-connrefused -O "${EXT_DL}"/sonar-jacoco-plugin-"${PLUG_JACOCO_VER}".jar \
  "${REPO_OFFICIAL}"/sonar-jacoco-plugin/sonar-jacoco-plugin-"${PLUG_JACOCO_VER}".jar \
  \
  && wget --retry-connrefused -O "${EXT_DL}"/sonar-java-plugin-"${PLUG_JAVA_VER}".jar \
  "${REPO_OFFICIAL}"/sonar-java-plugin/sonar-java-plugin-"${PLUG_JAVA_VER}".jar \
  \
  && wget --retry-connrefused -O "${EXT_DL}"/sonar-javascript-plugin-"${PLUG_JAVASCRIPT_VER}".jar \
  "${REPO_OFFICIAL}"/sonar-javascript-plugin/sonar-javascript-plugin-"${PLUG_JAVASCRIPT_VER}".jar \
  \
  && wget --retry-connrefused -O "${EXT_DL}"/sonar-kotlin-plugin-"${PLUG_KOTLIN_VER}".jar \
  "${REPO_OFFICIAL}"/sonar-kotlin-plugin/sonar-kotlin-plugin-"${PLUG_KOTLIN_VER}".jar \
  \
  && wget --retry-connrefused -O "${EXT_DL}"/sonar-ldap-plugin-"${PLUG_LDAP_VER}".jar \
  "${REPO_OFFICIAL}"/sonar-ldap-plugin/sonar-ldap-plugin-"${PLUG_LDAP_VER}".jar \
  \
  && wget --retry-connrefused -O "${EXT_DL}"/sonar-php-plugin-"${PLUG_PHP_VER}".jar \
  "${REPO_OFFICIAL}"/sonar-php-plugin/sonar-php-plugin-"${PLUG_PHP_VER}".jar \
  \
  && wget --retry-connrefused -O "${EXT_DL}"/sonar-python-plugin-"${PLUG_PYTHON_VER}".jar \
  "${REPO_OFFICIAL}"/sonar-python-plugin/sonar-python-plugin-"${PLUG_PYTHON_VER}".jar \
  \
  && wget --retry-connrefused -O "${EXT_DL}"/sonar-scm-git-plugin-"${PLUG_SCM_GIT_VER}".jar \
  "${REPO_OFFICIAL}"/sonar-scm-git-plugin/sonar-scm-git-plugin-"${PLUG_SCM_GIT_VER}".jar \
  \
  && wget --retry-connrefused -O "${EXT_DL}"/sonar-scm-svn-plugin-"${PLUG_SCM_SVN_VER}".jar \
  "${REPO_OFFICIAL}"/sonar-scm-svn-plugin/sonar-scm-svn-plugin-"${PLUG_SCM_SVN_VER}".jar \
  \
  && wget --retry-connrefused -O "${EXT_DL}"/sonar-scala-plugin-"${PLUG_SONARSCALA_VER}".jar \
  "${REPO_OFFICIAL}"/sonar-scala-plugin/sonar-scala-plugin-"${PLUG_SONARSCALA_VER}".jar \
  \  
  && wget --retry-connrefused -O "${EXT_DL}"/sonar-typescript-plugin-"${PLUG_TYPESCRIPT_VER}".jar \
  "${REPO_OFFICIAL}"/sonar-typescript-plugin/sonar-typescript-plugin-"${PLUG_TYPESCRIPT_VER}".jar \
  \
  && wget --retry-connrefused -O "${EXT_DL}"/sonar-xml-plugin-"${PLUG_XML_VER}".jar \
  "${REPO_OFFICIAL}"/sonar-xml-plugin/sonar-xml-plugin-"${PLUG_XML_VER}".jar \
  \
  && wget --retry-connrefused -O "${EXT_DL}"/sonar-css-plugin-"${PLUG_CSS_VER}".jar \
  "${REPO_OFFICIAL}"/sonar-css-plugin/sonar-css-plugin-"${PLUG_CSS_VER}".jar \
  \
  && wget --retry-connrefused -O "${EXT_DL}"/sonar-ruby-plugin-"${PLUG_RUBY_VER}".jar \
  "${REPO_OFFICIAL}"/sonar-ruby-plugin/sonar-ruby-plugin-"${PLUG_RUBY_VER}".jar \
  \
  && wget --retry-connrefused -O "${EXT_DL}"/sonar-vbnet-plugin-"${PLUG_VBNET}".jar \
  "${REPO_OFFICIAL}"/sonar-vbnet-plugin/sonar-vbnet-plugin-"${PLUG_VBNET}".jar \
  \
  && wget --retry-connrefused -O "${EXT_DL}"/sonarqube-community-branch-plugin-"${PLUG_BRANCH_VER}".jar \
  https://urldefense.com/v3/__https://github.com/mc1arke/sonarqube-community-branch-plugin/releases/download/*22$*7BPLUG_BRANCH_VER*7D*22/sonarqube-community-branch-plugin-*22$*7BPLUG_BRANCH_VER*7D*22.jar__;JSUlJSUlJSU!!IOGos0k!z75BPXvc_WSLoxP3xOSTSDxl0EcpoFuIbPZUdIOXkDrM0NmdlAjvfkmEV3gTwZzX9rdroaFV$  \
  \
  && wget --retry-connrefused -O "${EXT_DL}"/sonar-ansible-plugin-"${PLUG_ANSIBLE_VER}".jar \
  https://urldefense.com/v3/__https://github.com/sbaudoin/sonar-ansible/releases/download/v*22$*7BPLUG_ANSIBLE_VER*7D*22/sonar-ansible-plugin-*22$*7BPLUG_ANSIBLE_VER*7D*22.jar__;JSUlJSUlJSU!!IOGos0k!z75BPXvc_WSLoxP3xOSTSDxl0EcpoFuIbPZUdIOXkDrM0NmdlAjvfkmEV3gTwZzX9iRPvbdx$  \
  \
  && wget --retry-connrefused -O "${EXT_DL}"/sonar-checkstyle-plugin-"${PLUG_CHECKSTYLE_VER}".jar \
  https://urldefense.com/v3/__https://github.com/checkstyle/sonar-checkstyle/releases/download/*22$*7BPLUG_CHECKSTYLE_VER*7D*22/checkstyle-sonar-plugin-*22$*7BPLUG_CHECKSTYLE_VER*7D*22.jar__;JSUlJSUlJSU!!IOGos0k!z75BPXvc_WSLoxP3xOSTSDxl0EcpoFuIbPZUdIOXkDrM0NmdlAjvfkmEV3gTwZzX9iGxJSKK$  \
  \
  && wget --retry-connrefused -O "${EXT_DL}"/sonar-cobertura-plugin-"${PLUG_COBERTURA_VER}".jar \
  https://urldefense.com/v3/__https://github.com/galexandre/sonar-cobertura/releases/download/*22$*7BPLUG_COBERTURA_VER*7D*22/sonar-cobertura-plugin-*22$*7BPLUG_COBERTURA_VER*7D*22.jar__;JSUlJSUlJSU!!IOGos0k!z75BPXvc_WSLoxP3xOSTSDxl0EcpoFuIbPZUdIOXkDrM0NmdlAjvfkmEV3gTwZzX9lxQ_h2j$  \
  \
  && wget --retry-connrefused -O "${EXT_DL}"/sonar-findbugs-plugin-"${PLUG_FINDBUGS_VER}".jar \
  https://urldefense.com/v3/__https://github.com/spotbugs/sonar-findbugs/releases/download/*22$*7BPLUG_FINDBUGS_VER*7D*22/sonar-findbugs-plugin-*22$*7BPLUG_FINDBUGS_VER*7D*22.jar__;JSUlJSUlJSU!!IOGos0k!z75BPXvc_WSLoxP3xOSTSDxl0EcpoFuIbPZUdIOXkDrM0NmdlAjvfkmEV3gTwZzX9qs9H1pH$  \
  \
  && wget --retry-connrefused -O "${EXT_DL}"/sonar-groovy-plugin-"${PLUG_GROOVY_VER}".jar \
  https://urldefense.com/v3/__https://github.com/Inform-Software/sonar-groovy/releases/download/*22$*7BPLUG_GROOVY_VER*7D*22/sonar-groovy-plugin-*22$*7BPLUG_GROOVY_VER*7D*22.jar__;JSUlJSUlJSU!!IOGos0k!z75BPXvc_WSLoxP3xOSTSDxl0EcpoFuIbPZUdIOXkDrM0NmdlAjvfkmEV3gTwZzX9k4VX_Z1$  \
  \
  && wget --retry-connrefused -O "${EXT_DL}"/sonar-shellcheck-plugin-"${PLUG_SHELLCHECK_VER}".jar \
  https://urldefense.com/v3/__https://github.com/sbaudoin/sonar-shellcheck/releases/download/v*22$*7BPLUG_SHELLCHECK_VER*7D*22/sonar-shellcheck-plugin-*22$*7BPLUG_SHELLCHECK_VER*7D*22.jar__;JSUlJSUlJSU!!IOGos0k!z75BPXvc_WSLoxP3xOSTSDxl0EcpoFuIbPZUdIOXkDrM0NmdlAjvfkmEV3gTwZzX9m-MZr0o$  \
  \
  && wget --retry-connrefused -O "${EXT_DL}"/sonar-pmd-plugin-"${PLUG_PMD_VER}".jar \
  https://urldefense.com/v3/__https://github.com/SonarQubeCommunity/sonar-pmd/releases/download/*22$*7BPLUG_PMD_VER*7D*22/sonar-pmd-plugin-*22$*7BPLUG_PMD_VER*7D*22.jar__;JSUlJSUlJSU!!IOGos0k!z75BPXvc_WSLoxP3xOSTSDxl0EcpoFuIbPZUdIOXkDrM0NmdlAjvfkmEV3gTwZzX9mBkon_C$  \
  \
  && wget --retry-connrefused -O "${EXT_DL}"/sonar-yaml-plugin-"${PLUG_YAML_VER}".jar \
  https://urldefense.com/v3/__https://github.com/sbaudoin/sonar-yaml/releases/download/v*22$*7BPLUG_YAML_VER*7D*22/sonar-yaml-plugin-*22$*7BPLUG_YAML_VER*7D*22.jar__;JSUlJSUlJSU!!IOGos0k!z75BPXvc_WSLoxP3xOSTSDxl0EcpoFuIbPZUdIOXkDrM0NmdlAjvfkmEV3gTwZzX9phsLT2F$  \
  \
  && wget --retry-connrefused -O "${EXT_DL}"/sonar-scm-jazzrtc-plugin-"${PLUG_JAZZ_VER}".jar \
  https://urldefense.com/v3/__https://github.com/troosan/sonar-scm-jazzrtc/releases/download/*22$*7BPLUG_JAZZ_VER*7D*22/sonar-scm-jazzrtc-plugin-*22$*7BPLUG_JAZZ_VER*7D*22.jar__;JSUlJSUlJSU!!IOGos0k!z75BPXvc_WSLoxP3xOSTSDxl0EcpoFuIbPZUdIOXkDrM0NmdlAjvfkmEV3gTwZzX9swaBFKd$  \
  \
  && wget --retry-connrefused -O "${EXT_DL}"/sonar-cxx-plugin-"${PLUG_CXX_VER}".1853.jar \
  https://urldefense.com/v3/__https://github.com/SonarOpenCommunity/sonar-cxx/releases/download/cxx-*22$*7BPLUG_CXX_VER*7D*22/sonar-cxx-plugin-*22$*7BPLUG_CXX_VER*7D*22.1853.jar__;JSUlJSUlJSU!!IOGos0k!z75BPXvc_WSLoxP3xOSTSDxl0EcpoFuIbPZUdIOXkDrM0NmdlAjvfkmEV3gTwZzX9pPYWE29$  \
  \
  && wget --retry-connrefused -O "${EXT_DL}"/sonar-perl-plugin-"${PLUG_PERL_VER}"-all.jar \
  https://urldefense.com/v3/__https://github.com/sonar-perl/sonar-perl/releases/download/*22$*7BPLUG_PERL_VER*7D*22/sonar-perl-plugin-*22$*7BPLUG_PERL_VER*7D*22-all.jar__;JSUlJSUlJSU!!IOGos0k!z75BPXvc_WSLoxP3xOSTSDxl0EcpoFuIbPZUdIOXkDrM0NmdlAjvfkmEV3gTwZzX9rAaifld$  \
  \
  && wget --retry-connrefused -O "${EXT_DL}"/sonar-clojure-plugin-"${PLUG_CLOJURE_VER}".jar \
  https://urldefense.com/v3/__https://github.com/fsantiag/sonar-clojure/releases/download/v*22$*7BPLUG_CLOJURE_VER*7D*22/sonar-clojure-plugin-*22$*7BPLUG_CLOJURE_VER*7D*22.jar__;JSUlJSUlJSU!!IOGos0k!z75BPXvc_WSLoxP3xOSTSDxl0EcpoFuIbPZUdIOXkDrM0NmdlAjvfkmEV3gTwZzX9sAz6R3T$  \
  \
  && chown -R "${SONARQUBE_UID}":"${SONARQUBE_GID}" "${EXT_DL}" \
  ;

# The following 4 lines must be only added for community version ( branching plugin )

RUN (cd /opt/sonarqube/lib/common/ && \
     wget --retry-connrefused https://urldefense.com/v3/__https://github.com/mc1arke/sonarqube-community-branch-plugin/releases/download/*22$*7BPLUG_BRANCH_VER*7D*22/sonarqube-community-branch-plugin-*22$*7BPLUG_BRANCH_VER*7D*22.jar__;JSUlJSUlJSU!!IOGos0k!z75BPXvc_WSLoxP3xOSTSDxl0EcpoFuIbPZUdIOXkDrM0NmdlAjvfkmEV3gTwZzX9rdroaFV$  \
     && chown "${SONARQUBE_UID}":"${SONARQUBE_GID}" sonarqube-community-branch-plugin-"${PLUG_BRANCH_VER}".jar )

# Adding EGAD root certificate
RUN /usr/lib/jvm/jre-11-openjdk/bin/keytool -import -trustcacerts  -alias EGADRootCA  -keystore /usr/lib/jvm/jre-11-openjdk/lib/security/cacerts -file  /etc/ssl/certs/EGADRootCA  -storepass changeit -trustcacerts -noprompt

WORKDIR "${SONARQUBE_HOME}"

COPY --chown=sonarqube:sonarqube run.sh "${SONARQUBE_HOME}/bin/run.sh"

USER "${SONARQUBE_UID}"

ENTRYPOINT ["bash","./bin/run.sh"]
