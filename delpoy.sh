#/bin/sh
cd /Users/bytedance/workspace/blog
hugo
cd public
git add .
git commit -m $1
git push origin gh-pages
cd ..
git add .
git commit -m $1
git push github master