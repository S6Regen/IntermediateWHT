# IntermediateWHT
Intermediate calculations of the Walsh Hadamard transform for neural networks and associative memory.

On a dedicated chip it should be possible to do 1 large Walsh Hadamard transform per clock cycle by filling the chip with addition, subtraction and bit shift circuts in a certain pattern, and by pipelining. With that you could construct really optimal neural networks and associative memory.  

Until that day arrives the intermediate calculations of the out-of-place Walsh Hadamard transform are quite viable for constructing high speed neural networks and associative memory.

The code is in FreeBasic.  

The intermediate step is to go pairwise through the input elements and place the sum of those in the lower half of the receiving array and the difference in the upper half, sequentially.  Then scale by 1/sqr(2) to leave the vector length unchanged. 

This is not exactly totally new as I used somewhat similar ideas in a neural network article for Servo magazine 15 or 20 years ago.
Don't blame me for the slow uptake of such ideas, there has been nothing but total and utter resistance. Even though there are serious gains to be had.
Now that big money is involved ($billions) maybe people will try better, though I wouldn't actually be too sure about it. Also nondisclosing players could be decades ahead if they had paid early attention.
