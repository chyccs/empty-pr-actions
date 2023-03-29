#! /bin/bash

while getopts b:h:n:p:i:o:e:r: flag
do
    case "${flag}" in
        b) base_branch=${OPTARG};;
        h) head_branch=${OPTARG};;
        n) number=${OPTARG};;
        p) pull_request_title=${OPTARG};;
        i) issue_title=${OPTARG};;
        o) owner=${OPTARG};;
        e) email=${OPTARG};;
        r) repo=${OPTARG};;
    esac
done

if [ -z $head_branch ]
then
    head_branch=${issue_title//:/ }
    head_branch=${head_branch//./ }
    head_branch="$number-$(~/.cargo/bin/ccase -b ' ' -t kebab "$head_branch" | ~/.cargo/bin/ccase -f pascal -t kebab)"
fi

if [ -z $pull_request_title ]
then
    issue_title_converted="$(~/.cargo/bin/ccase -f pascal -t kebab "$issue_title")"
    tag=$(echo "$issue_title_converted" | sed 's/\(.*\)\:\(.*\)/\1/g')
    contents=$(echo "$issue_title_converted" | sed 's/\(.*\)\:\(.*\)/\2/g')
    pull_request_title=$(echo "$tag: #$number $contents")
fi

gh issue develop -c "$number" --name "$head_branch" --base "$base_branch" --repo "$repo"
git checkout "$head_branch"
git config --local user.email "$email"
git config --local user.name "$owner"
git commit --allow-empty -m "trigger notification\n[skip ci]"
git push --set-upstream origin "$head_branch"
gh pr create --title "$pull_request_title" --body " " --repo "$repo" --base "$base_branch" --head "$head_branch"
