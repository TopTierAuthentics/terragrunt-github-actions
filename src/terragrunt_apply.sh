#!/bin/bash

function terragruntApply {
# Authenticate with GKE using INPUT_ prefixed environment variables
  echo "Authenticating with GKE cluster ${INPUT_CLUSTER_NAME} in region ${INPUT_REGION}"
  gcloud auth activate-service-account --key-file="${INPUT_GOOGLE_CREDENTIALS}"
  gcloud container clusters get-credentials "${INPUT_CLUSTER_NAME}" --region "${INPUT_REGION}" --project "${INPUT_PROJECT_ID}"

# Gather the output of `terragrunt apply`.
  echo "apply: info: applying Terragrunt configuration in ${tfWorkingDir}"
  applyOutput=""
  if [ "${tgActionsRunAll}" -eq 1 ]; then
    applyOutput=$(${tfBinary} run-all apply --terragrunt-non-interactive --terragrunt-source ../../../modules// -input=false ${*} 2>&1)
  else
    applyOutput=$(${tfBinary} apply --terragrunt-non-interactive -input=false ${*} 2>&1)
  fi


  applyExitCode=${?}
  applyCommentStatus="Failed"

  # Exit code of 0 indicates success. Print the output and exit.
  if [ "${applyExitCode}" -eq 0 ]; then
    echo "apply: info: successfully applied Terragrunt configuration in ${tfWorkingDir}"
    echo "${applyOutput}"
    echo
    applyCommentStatus="Success"
  fi

  # Exit code of !0 indicates failure.
  if [ "${applyExitCode}" -ne 0 ]; then
    echo "apply: error: failed to apply Terragrunt configuration in ${tfWorkingDir}"
    echo "${applyOutput}"
    echo
  fi

  # Comment on the pull request if necessary.
  if [ "$GITHUB_EVENT_NAME" == "pull_request" ] && [ "${tfComment}" == "1" ]; then
    applyCommentWrapper="#### \`${tfBinary} apply\` ${applyCommentStatus}
<details><summary>Show Output</summary>

\`\`\`
${applyOutput}
\`\`\`

</details>

*Workflow: \`${GITHUB_WORKFLOW}\`, Action: \`${GITHUB_ACTION}\`, Working Directory: \`${tfWorkingDir}\`, Workspace: \`${tfWorkspace}\`*"

    applyCommentWrapper=$(stripColors "${applyCommentWrapper}")
    echo "apply: info: creating JSON"
    applyPayload=$(echo "${applyCommentWrapper}" | jq -R --slurp '{body: .}')
    applyCommentsURL=$(cat ${GITHUB_EVENT_PATH} | jq -r .pull_request.comments_url)
    echo "apply: info: commenting on the pull request"
    echo "${applyPayload}" | curl -s -S -H "Authorization: token ${GITHUB_TOKEN}" --header "Content-Type: application/json" --data @- "${applyCommentsURL}" > /dev/null
  fi

  exit ${applyExitCode}
}
