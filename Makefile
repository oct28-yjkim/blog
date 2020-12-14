pull:
	echo "1"

run: 
	docker run --rm -it --name hugo -d \
		-v ${PWD}:/src \
		-p 1313:1313 \
		klakegg/hugo:0.78.2-ext-alpine server 

stop:
	docker stop hugo
		
exec: 
	docker exec -it hugo bash 
	
new: 
	# example : make new FN=test2
	## result : docker exec -it hugo hugo new posts/test2.md
	## result : /src/content/en/posts/test2.md created
	docker exec -it hugo hugo new posts/$(FN).md
	docker exec -it hugo sh -c "chown -R 1000:1001 /src/content/en/posts/*.md"
	
build: 
	docker exec -it hugo hugo -t zzo --debug -v 
	docker exec -it hugo sh -c "chown -R 1000:1001 /src/public/*"
	
push_static:
	sh push.sh
#cd public
#git add . -A
#git commit -m "update blog `date`"
#git push origin master ;
	
push: 
	git add . -A;
	git commit -m "update blog project `date`";
	git push origin master ;

