#include once "vecops10.bas"
#include once "xfile.bas"

type amnet
	veclen as ulongint
	density as ulongint
	hash as ulongint
	rate as single
	steps as ulongint
	weights(any) as single
	surface(any) as single 
	workA(any) as single
	workB(any) as single
	workC(any) as single
    declare sub init(veclen as ulongint,density as ulongint,rate as single, hash as ulongint)
    declare sub train(targetVec as single ptr,inVec as single ptr)
    declare sub recall(resultVec as single ptr,inVec as single ptr)
    declare sub recallSurface(resultVec as single ptr,inVec as single ptr)
    declare sub sizememory()
    declare sub load()
    declare sub save()
end type

sub amnet.init(veclen as ulongint,density as ulongint,rate as single,hash as ulongint)
	this.veclen=veclen
	this.density=density
	this.hash=hash
	this.steps=bitscanreverse(veclen)
	this.rate=rate/(steps*density)
	sizememory()
end sub

sub amnet.sizememory()
    redim weights(steps*density*veclen-1)
    redim surface(steps*density*veclen-1)
	redim workA(vecLen-1)
	redim workB(vecLen-1)
	redim workC(vecLen-1)
end sub

sub amnet.recall(resultVec as single ptr,inVec as single ptr)
    dim as single ptr wts=@weights(0),wa=@workA(0),wb=@workB(0)
	adjust(wa,inVec,1!,veclen)
	hashflip(wa,wa,hash-1,veclen)
	whtq(wa,veclen)
	zero(resultVec,veclen)
	for i as ulongint=0 to density-1
	   hashflip(wa,wa,hash+i,veclen)
	   for j as ulongint=0 to steps-1
	      hstep(wb,wa,veclen)
	      swap wa,wb
	      signedsqr(wb,wa,veclen)
	      multiplyaddto(resultVec,wb,wts,veclen)
	      wts+=veclen
	    next
	next
end sub

sub amnet.recallSurface(resultVec as single ptr,inVec as single ptr)
    dim as single ptr wts=@weights(0),sur=@surface(0),wa=@workA(0),wb=@workB(0)
	adjust(wa,inVec,1!,veclen)
	hashflip(wa,wa,hash-1,veclen)
	whtq(wa,veclen)
	zero(resultVec,veclen)
	for i as ulongint=0 to density-1
	   hashflip(wa,wa,hash+i,veclen)
	   for j as ulongint=0 to steps-1
	      hstep(wb,wa,veclen)
	      swap wa,wb
	      signedsqr(wb,wa,veclen)
	      copy(sur,wb,veclen)
	      multiplyaddto(resultVec,wb,wts,veclen)
	      wts+=veclen
	      sur+=veclen
	    next
	next
end sub

sub amnet.train(targetVec as single ptr,inVec as single ptr)
    dim as single ptr wts=@weights(0),sur=@surface(0),wc=@workC(0)
	recallSurface(wc,inVec)
	subtract(wc,targetVec,wc,veclen)
	scale(wc,wc,rate,veclen)
	for i as ulongint =0 to steps*density-1
	   multiplyaddto(wts,sur,wc,veclen)
	   wts+=veclen
	   sur+=veclen
	next
end sub

'save using xfile
sub amnet.save()
	xfile.save(veclen)
	xfile.save(density)
	xfile.save(hash)
	xfile.save(rate)
	xfile.save(weights())
end sub

sub amnet.load()
	xfile.load(veclen)
	xfile.load(density)
	xfile.load(hash)
	xfile.load(rate)
	steps=bitscanreverse(veclen)
    sizememory()
    xfile.load(weights())
end sub
