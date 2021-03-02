FROM tomcat:8.0
MAINTAINER prpr00001@nagarro.com
RUN rm -rf /usr/local/tomcat/webapps/*
COPY ./target/devopssampleapplication.war /usr/local/tomcat/webapps/sameerkataria.war
EXPOSE 8080
CMD ["catalina.sh","run"]