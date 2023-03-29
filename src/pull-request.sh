#! /bin/bash

while getopts b:h:n:p:i:o:e:l:r: flag
do
    case "${flag}" in
        b) base_branch=${OPTARG};;
        h) head_branch=${OPTARG};;
        n) number=${OPTARG};;
        p) pull_request_title=${OPTARG};;
        i) issue_title=${OPTARG};;
        o) owner=${OPTARG};;
        e) email=${OPTARG};;
        l) login=${OPTARG};;
        r) repo=${OPTARG};;
    esac
done

if [ -z $head_branch ]
then
    issue_title_converted=$(echo "$issue_title" | sed 's/\([^a-zA-Z0-9]\)/ /g' )
    head_branch="$number-$(~/.cargo/bin/ccase -b ' ' -t kebab "$issue_title_converted" | ~/.cargo/bin/ccase -f pascal -t kebab)"
fi

if [ -z $pull_request_title ]
then
    issue_title_converted="$(~/.cargo/bin/ccase -f pascal -t kebab "$issue_title")"
    tag=$(echo "$issue_title_converted" | sed 's/\(.*\)\:\(.*\)/\1/g')
    contents=$(echo "$issue_title_converted" | sed 's/\(.*\)\:\(.*\)/\2/g')
    pull_request_title=$(echo "$tag: #$number $contents")
fi

echo "::debug::head_branch=$head_branch"
echo "::debug::pull_request_title=$pull_request_title"

gh issue develop -c "$number" --name "$head_branch" --base "$base_branch" --repo "$repo"
result=$?
echo "::debug::gh issue develop -c $number --name "$head_branch" --base $base_branch --repo $repo => $result"

if [ $result -eq 0 ]
then
    git config --local user.email "$email"
    git config --local user.name "$owner"
    git commit --allow-empty -m "trigger notification\n[skip ci]"
    
    git push --set-upstream origin "$head_branch"
    echo "::debug::git push --set-upstream origin $head_branch"
    
    if [ -z $login ]
    then
        assignee=$(echo " -a $login")
    else  
        assignee=""
    fi

    new_pr=$(gh pr create --title "$pull_request_title" --repo "$repo" --base "$base_branch" --head "$head_branch" --body-file ".github/pull_request_template.md"$assignee)
    echo "::debug::gh pr create --title $pull_request_title --body ' ' --repo $repo --base $base_branch --head $head_branch"

    gh issue comment $number --body "Pull Request created. $new_pr" --repo $repo
else
    echo "::debug::branch is already created"
    gh issue comment $number --body "Can not create Pull Request. Branch is already exists" --repo $repo
fi
