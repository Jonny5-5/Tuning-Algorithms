// /*
// complex fast fourier transform and inverse from
// http://rosettacode.org/wiki/Fast_Fourier_transform#C.2B.2B
// */
// import 'dart:math';

// icfft(amplitudes)
// {
// 	var N = amplitudes.length;
// 	var iN = 1 / N;
	
// 	//conjugate if imaginary part is not 0
// 	for(var i = 0 ; i < N; ++i)
// 		if(amplitudes[i] is Complex)
// 			amplitudes[i].im = -amplitudes[i].im;
			
// 	//apply fourier transform
// 	amplitudes = cfft(amplitudes);
	
// 	for(var i = 0 ; i < N; ++i)
// 	{
// 		//conjugate again
// 		amplitudes[i].im = -amplitudes[i].im;
// 		//scale
// 		amplitudes[i].re *= iN;
// 		amplitudes[i].im *= iN;
// 	}
// 	return amplitudes;
// }

// cfft(amplitudes)
// {
// 	var N = amplitudes.length;
// 	if( N <= 1 )
// 		return amplitudes;
	
// 	var hN = N / 2;
// 	var even = [];
// 	var odd = [];
// 	even.length = hN;
// 	odd.length = hN;
// 	for(var i = 0; i < hN; ++i)
// 	{
// 		even[i] = amplitudes[i*2];
// 		odd[i] = amplitudes[i*2+1];
// 	}
// 	even = cfft(even);
// 	odd = cfft(odd);
	
// 	var a = -2 * pi;
// 	for(var k = 0; k < hN; ++k)
// 	{
// 		if(!(even[k] is Complex))
// 			even[k] = new Complex(even[k], 0);
// 		if(!(odd[k] is Complex))
// 			odd[k] = new Complex(odd[k], 0);
// 		var p = k/N;
// 		var t = new Complex(0, a * p);
// 		t.cexp(t).mul(odd[k], t);
// 		amplitudes[k] = even[k].add(t, odd[k]);
// 		amplitudes[k + hN] = even[k].sub(t, even[k]);
// 	}
// 	return amplitudes;
// }


// /*
// basic complex number arithmetic from 
// http://rosettacode.org/wiki/Fast_Fourier_transform#Scala
// */
// class Complex{
//   double re;
//   double im;

//   Complex(re, im) {
//     this.re = re;
//     this.im = 0.0;
//   }

//   Complex operator + (other, dst) {
//     dst.re = this.re + other.re;
//     dst.im = this.im + other.im;
//     return dst;
//   }

//   Complex operator - (other, dst){
//     dst.re = this.re - other.re;
//     dst.im = this.im - other.im;
//     return dst;
//   }

//   Complex operator * (other, dst)
//   {
//     //cache re in case dst === this
//     var r = this.re * other.re - this.im * other.im;
//     dst.im = this.re * other.im + this.im * other.re;
//     dst.re = r;
//     return dst;
//   }

//   Complex operator ^ (dst)
//   {
//     var er = exp(re);
//     dst.re = er * cos(this.im);
//     dst.im = er * sin(this.im);
//     return dst;
//   }

//   Complex log()
//   {
//     /*
//     although 'It's just a matter of separating out the real and imaginary parts of jw.' is not a helpful quote
//     the actual formula I found here and the rest was just fiddling / testing and comparing with correct results.
//     http://cboard.cprogramming.com/c-programming/89116-how-implement-complex-exponential-functions-c.html#post637921
//     */
//     if( !re )
//       print(this.im.toString()+'j');
//     else if( this.im < 0 )
//       print(this.re.toString()+this.im.toString()+'j');
//     else
//       print(this.re.toString()+'+'+this.im.toString()+'j');
//   }
// }