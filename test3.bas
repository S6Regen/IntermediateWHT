#include "net3.bas"
#include "rnd256.bas"
#include "image.bas"
#include "file.bi"

#define IMGFolder "photos"
#define VALRatio .75
#define NETFile "netam.dat"

#define IMGSize 64 ' edge size of image

#define NETDensity 2
#define NETDepth 3
#define NETHash 123456
#define NETSize 4*IMGSize*IMGSize

#define NThreads 2
#define Mutations 25

'collect everything for threads 
namespace thr
	dim as evonet parent,children(NThreads-1)
	dim as any ptr threads(NThreads-1)
	dim as boolean shouldRun
	dim as any ptr mutex
	dim as single parentcost,images(),work(NETSize)
	dim as ulong imgrecall,imgtrain
	dim as ulongint trainingiter
	dim as rnd256 rng
    sub init()
      rng.init()
      mutex=mutexcreate()
      if fileExists(NETFile) then
		print "Loading Network..."
		xfile.openfile(NETFile)
		parent.load()
		xfile.load(parentcost)
		xfile.load(trainingiter)
		xfile.closefile()
	  else
		print "Creating Network..."
		parent.init(NETSize,NETDensity,NETDepth,NETHash)
		for i as ulongint=0 to ubound(parent.weights)
			parent.weights(i)=rng.nextsinglesym()
		next
		parentcost=1!/0!	'positive infinity 
	  end if
      for i as ulong=0 to ubound(children)
		children(i).init(NETSize,NETDensity,NETDepth,NETHash)
	  next
	  print "Loading training images..."
	  imgrecall=loadimages(IMGFolder,images(),IMGSize)
	  imgtrain=VALRatio*imgrecall
    end sub
    
    sub submit(childcost as single,child as ulong)
		mutexlock(mutex)
		dim as ulongint m=ubound(parent.weights)
		if childcost<parentcost then
			parentcost=childcost
			copy(@parent.weights(0),@children(child).weights(0),m+1)
		else
		    copy(@children(child).weights(0),@parent.weights(0),m+1)
		end if
		for i as ulong=0 to Mutations-1
		   dim as ulong r=rng.nextinc(m)
		   dim as single v=children(child).weights(r)
		   dim as single m=v+rng.nextmutation()
		   if m<-1! then m=v
		   if m>1! then m=v
		   children(child).weights(r)=m
		next
		trainingiter+=1
		mutexunlock(mutex)
	end sub
	
	sub threadsub(x as any ptr)
		dim as ulong child=cast(ulongint,x) 'culng(x) 'cast x to ulong, the child network for this thread
		dim as single work(NETSize-1)
		while shouldRun
			dim as single childcost=0!
			for i as ulong=0 to imgtrain-1
				children(child).recall(@work(0),@images(i*NETSize))
				childcost+=errorl2(@work(0),@images(i*NETSize),NETSize)
			next
			submit(childcost,child)	
		wend
	end sub
    
	sub startTraining()
		for i as ulong=0 to ubound(children)
			submit(1!/0!,i) 'get initial mutation using fake infinite cost
	    next
	    shouldRun=true 'flag for threads to run
	    for i as ulongint=0 to ubound(threads)
			threads(i)=threadcreate(@threadsub,cast(any ptr,i)) 'cast i to any pointer
		next
	end sub
	
	sub stopTraining()
		shouldRun=false
		for i as ulong=0 to ubound(threads)
		   threadwait(threads(i))
		next
		xfile.openfile(NETFile)
        parent.save()
        xfile.save(parentcost)
        xfile.save(trainingiter)
        xfile.closefile()
	end sub
	
end namespace

screenres 400,400,32
dim as boolean training,recall
dim as ulong rcount
dim as single work(NETSize-1)
thr.init()
do
  var k=inkey()
  if (k="t") or (k="T") and not recall then
    if training then
       thr.stopTraining()
    else
       thr.startTraining()
    end if 
    training=not training
  end if
  if (k="r") or (k="R") and not training then recall=not recall
  if k=chr(27) then exit do
  if (not training) and (not recall) then
   cls
   print "T to Train, R to Recall"
   sleep 300
  end if
  if training then
	cls
	print "Iterations:",thr.trainingiter
	print "Cost:",thr.parentcost
	sleep 1000
  end if
  if recall then
    cls
    print "Recall",rcount,iif(rcount<thr.imgtrain,"T set","Val set")
    thr.parent.recall(@work(0),@thr.images(rcount*NETSize))
	presentimage(100,100,@work(0),IMGSize)
	rcount+=1
	if rcount=thr.imgrecall then rcount=0
	sleep 2000
  end if
loop

