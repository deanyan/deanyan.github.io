deploy:
	git co development
	jekyll build
	git add -A
	git ci -m "Push code before release"
	cp -r _site /tmp/
	git co master
	cp -r /tmp/_site/* ./
	git add -A
	git ci -m "Deploy site to github server"
	git push origin master
	git co development
    echo "Switch to branch development, deploy to github server succeed"
    git push origin development
    echo "Push development code to github repo"
