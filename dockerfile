FROM eclipse-temurin:8-jdk

LABEL maintainer="CTF Lab - Intentionally Vulnerable"

# Hardcoded secrets (real-world mistake)
ENV GLASSFISH_VERSION=4.1 \
    GLASSFISH_HOME=/opt/glassfish4 \
    ADMIN_PASSWORD=admin \
    DB_PASSWORD=root123 \
    AWS_SECRET=AKIAFAKEKEY123456

ENV PATH="${GLASSFISH_HOME}/bin:${PATH}"

# Install unnecessary and dangerous tools
RUN apt-get update && \
    apt-get install -y \
        wget unzip \
        net-tools \
        curl \
        vim \
        nano \
        python \
        openssh-server \
        telnet \
        netcat \
    && rm -rf /var/lib/apt/lists/*

# Weak SSH setup
RUN echo "root:root" | chpasswd && \
    mkdir /var/run/sshd

# Download GlassFish
RUN wget --no-check-certificate https://download.oracle.com/glassfish/4.1/release/glassfish-4.1.zip -O /tmp/glassfish.zip && \
    unzip -q /tmp/glassfish.zip -d /opt && \
    rm /tmp/glassfish.zip

WORKDIR ${GLASSFISH_HOME}

# Start domain ONCE just to configure it
RUN asadmin start-domain domain1 && \
    \
    # DO NOT change admin password (leave blank)
    \
    # Enable remote admin access
    asadmin set server.admin-service.das-config.remote-access-enabled=true && \
    \
    # Disable secure admin (HTTP admin panel)
    asadmin disable-secure-admin && \
    \
    asadmin stop-domain domain1

# Make everything world-writable (terrible practice)
RUN chmod -R 777 ${GLASSFISH_HOME}

# Add vulnerable JSP (LFI)
RUN mkdir -p ${GLASSFISH_HOME}/glassfish/domains/domain1/autodeploy && \
    echo '<%@ page import="java.io.*" %>' > ${GLASSFISH_HOME}/glassfish/domains/domain1/autodeploy/shell.jsp && \
    echo '<%' >> ${GLASSFISH_HOME}/glassfish/domains/domain1/autodeploy/shell.jsp && \
    echo 'String cmd = request.getParameter("cmd");' >> ${GLASSFISH_HOME}/glassfish/domains/domain1/autodeploy/shell.jsp && \
    echo 'if(cmd != null){' >> ${GLASSFISH_HOME}/glassfish/domains/domain1/autodeploy/shell.jsp && \
    echo 'Process p = Runtime.getRuntime().exec(cmd);' >> ${GLASSFISH_HOME}/glassfish/domains/domain1/autodeploy/shell.jsp && \
    echo 'BufferedReader r = new BufferedReader(new InputStreamReader(p.getInputStream()));' >> ${GLASSFISH_HOME}/glassfish/domains/domain1/autodeploy/shell.jsp && \
    echo 'String line; while((line = r.readLine()) != null){ out.println(line+"<br>"); }' >> ${GLASSFISH_HOME}/glassfish/domains/domain1/autodeploy/shell.jsp && \
    echo '}' >> ${GLASSFISH_HOME}/glassfish/domains/domain1/autodeploy/shell.jsp && \
    echo '%>' >> ${GLASSFISH_HOME}/glassfish/domains/domain1/autodeploy/shell.jsp

# Flag in multiple locations
RUN echo "CTF{multi_vector_compromise}" > /flag.txt && \
    echo "CTF{backup_flag}" > /root/flag.txt && \
    chmod 666 /flag.txt

# Expose EVERYTHING (real-world bad config)
EXPOSE 22 21 23 25 53 80 443 8080 8181 4848 9009 3306 6379

# Start SSH + GlassFish + Debug mode
CMD service ssh start && \
    asadmin start-domain --debug --verbose domain1
