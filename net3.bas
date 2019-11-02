#include once "vecops10.bas"
#include once "xfile.bas"

type evonet
	veclen as ulongint
	density as ulongint
	depth as ulongint
	hash as ulongint
	steps as ulongint
	weights(any) as single
	workA(any) as single
	workB(any) as single
    declare sub init(veclen as ulongint,density as ulongint,depth as ulongint,hash as ulongint)
    declare sub recall(resultVec as single ptr,inVec as single ptr)
    declare sub sizememory()
    declare sub load()
    declare sub save()
end type

sub evonet.init(veclen as ulongint,density as ulongint,depth as ulongint,hash as ulongint)
	this.veclen=veclen
	this.density=density
	this.depth=depth
	this.hash=hash
	this.steps=bitscanreverse(veclen)
	sizememory()
end sub

sub evonet.sizememory()
    redim weights(2*steps*density*depth*veclen-1)
	redim workA(vecLen-1)
	redim workB(vecLen-1)
end sub

sub evonet.recall(resultVec as single ptr,inVec as single ptr)
    dim as single ptr wts=@weights(0),wa=@workA(0),wb=@workB(0)
    dim as single sc=1.7!/sqr(steps*density) 'guess at constant - should work out properly!!!
    dim as ulongint h=hash
	adjust(wa,inVec,sc,veclen)
	hashflip(wa,wa,h,veclen)
	whtq(wa,veclen)
	for i as ulongint=0 to depth-1
		zero(resultVec,veclen)
		for j as ulongint=0 to density-1
		   h+=1
		   hashflip(wa,wa,h,veclen)
		   for k as ulongint=0 to steps-1
			  hstep(wb,wa,veclen)
			  swap wa,wb
			  switchaddto(resultVec,wa,wts,veclen)
			  wts+=2*veclen
			next
		next
		if i<>depth-1 then scale(wa,resultVec,sc,veclen)
	next
end sub

'save using xfile
sub evonet.save()
	xfile.save(veclen)
	xfile.save(density)
	xfile.save(depth)
	xfile.save(hash)
	xfile.save(weights())
end sub

sub evonet.load()
	xfile.load(veclen)
	xfile.load(density)
	xfile.load(depth)
	xfile.load(hash)
	steps=bitscanreverse(veclen)
    sizememory()
    xfile.load(weights())
end sub
