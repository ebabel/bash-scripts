#!/bin/bash  

#
# Run this tool in a repo after commiting with a message containing "[jira:PNC-1030]",
# this tool will update the 'Build Fixed' field in jira to the next build number in jenkins.
#
#

source "$HOME/.updateJIRAbuildFixed" # Load USERNAME and PASSWORD and JENKINS_URL and JIRA_URL vars

#set -x # echo on
set -e # exit on error


RESPONSE=`wget -qO- --auth-no-challenge --http-user=${USERNAME} --http-password=${PASSWORD} ${JENKINS_URL}/view/All/cc.xml`


BUILD=`echo "${RESPONSE}" | sed -E 's/^.*lastBuildLabel="([0-9]*)".*$/\1/'`
BUILD=$(expr $BUILD + 1)




LOGMSG=$(svn log -r HEAD | grep '\[jira:PNC-')


JIRA_TICKET=`echo "${LOGMSG}" | sed -E 's/^.*jira:(PNC-[0-9]*)].*$/\1/'`


# https://dzone.com/articles/useful-subversion-pre-commit
# https://developer.atlassian.com/jiradev/jira-apis/jira-rest-apis/jira-rest-api-tutorials/jira-rest-api-example-edit-issues
# To see where customfield_10094 came from, run this:
# RESPONSE2=`wget -qO- --auth-no-challenge --http-user=${USERNAME} --http-password=${PASSWORD} "${JIRA_URL}/rest/api/2/issue/${JIRA_TICKET}/editmeta" `
# echo "BUILD FIXED FIELD="
# customfield_10094":"162"


#
curl --silent -D- -u ${USERNAME}:${PASSWORD} -X PUT --data "{ \"fields\": { \"customfield_10094\":\"${BUILD}\" } }" -H "Content-Type: application/json" ${JIRA_URL}/rest/api/2/issue/${JIRA_TICKET} > /dev/null



set +x # echo off

echo
echo "Updated Ticket"
echo "  URL: ${JIRA_URL}/browse/${JIRA_TICKET}"
echo "  Build Fixed: ${BUILD}"
echo
