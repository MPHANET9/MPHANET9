#include <stdio.h>
#include <stdbool.h>

/*
	@ A program that prints the first 10 reversible square primes
	@Thabang Mphane 202000689
	@20 October 2022
*/

/*
	1. Find the prime numbers
	2. Square the prime numbers
	3. Store them in an array
	4. Reverse the number; then: i)Check for Palindromes
								 ii)Check for a reversed match and print
*/

unsigned long   digitSize(unsigned long integer),
		  		Reverse(unsigned long integer),
		  		Exponent(unsigned long integer,unsigned long exit);

int main()
{
	unsigned long size = 10000;
	unsigned long i = 0;
	unsigned long length =0;
	unsigned long sq_primes[size];
	unsigned long exit = 0;
	
	for(unsigned long number= 2; number <= 10000; number++) //Checking for Prime squared numbers and storing them in an array
	{
		unsigned long isprime = true; //isprime != 0
		if(number == 2)
		{
			sq_primes[i] = number*number; //Step 2 and Step 3
			length++;
			i++;
		}
		else
		{
			for(unsigned long count=2; count < number && isprime; count++) //numbers less than the number we are checking
			{
				if(number%count == 0) //Step 1
				{
					isprime = false; //isprime == 0
				}
				else
				{
					isprime = true; //isprime != 0
				}
			}
			if(isprime)
			{
				sq_primes[i] = number*number; //Step 2 and Step 3
				length++;
				i++;
			}
		}
	}
	
	printf("These are the first 10 reversible square primes\n\n");
	
	for(unsigned long counter = 0; counter < length; counter++) //Selecting a number from the array to reverse and atch with other numbers from the array
	{
		if(sq_primes[counter] != Reverse(sq_primes[counter])) //Step 4i
		{
			for(unsigned long count = 0; count < length; count++) //If the number is not a Palindrome' match its reverse with all the numbers in the array
			{
				if(Reverse(sq_primes[counter]) == sq_primes[count] && exit < 10) //Step 4ii
				{
					printf("%d\n", sq_primes[counter]); //print the number that was reversed
					exit++;
				}
			}
		}	
	}
	
	return 1;
}

 unsigned long digitSize(unsigned long integer) //Gets the number of digits in an integer; to use in reversing the numbers
{
	unsigned long width = 0;
	
	while(integer != 0)
	{
		integer = integer/10;
		width++;
	}
	
	return width;
}

 unsigned long Reverse(unsigned long integer) //Reverses the given integer
{
	unsigned long rev = 0;
	unsigned long exit = 1;
	unsigned long temporary = integer;        //To keep our argument constant
	while(temporary != 0)
	{
		rev = (temporary%10)*(Exponent(integer,exit)) + rev; //Use the place holder theorem; then add the digits at the place values to get the number reversed
		temporary = temporary/10;
		exit = exit + 1;
	}
			
	return rev;
}

 unsigned long Exponent(unsigned long integer,unsigned long exit)
{
	unsigned long expo = (digitSize(integer)-exit);
	unsigned long std_form = 1;
	while(expo != 0)
	{
		std_form *= 10;
		expo--;
	}
	return std_form;
}