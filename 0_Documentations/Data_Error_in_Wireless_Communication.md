# Data Error in Wireless Communication

## 1	BPSK Modulation System

### 1.1	Overview

Let the bit error probability caused by channel and additive Gaussian white noise be $Pe$. That is to say, if a symbol (equals to a bit in BPSK system) $a$ or $-a$ is transmitted through a wireless channel, the receiving detector has the probability $Pe$ to mistake it for the opposite symbol $-a$ or $a$.

Assume that a decimal digit is transmitted in a packet of 4 bits, i.e. one digit is represented by four bits $\{ x_4\ x_3\ x_2\ x_1 \}$ and the range of the digit is $[0,15]$. For example, If the transmitted digit is 10, the actual bit stream transmitted by the system is 1010 and if the transmitted digit is 0, the system will transmit 0000 instead of a single 0.

Define data error as $\vert Digit_{Tx} - Digit_{Rx} \vert$, the purpose of our work is to study the distribution of data error and see if there is any possibility to control the error distribution manually. Since the digits are regenerated after the digital receiver, it is clear that the error distribution is directly related to $P_e$. According to the theory of wireless communication, $P_e$ is only related to the signal-to-noise ratio in a fixed-channel wireless communication system and channel noise power usually remains constant over time. Therefore, the purpose of our study shifts to controlling the data error distribution by regulating the transmit power.

Apparently, for different digits being transmitted, the possible data error is different and the error distribution seems to be complicated. So, let us start with a simple case where the transmitted digits are uniformly distributed between the widest digit range, e.g. $[0,15]$ for a 4-bit packet.

### 1.2	Transmit Random Digits (Uniformly Distributed)

#### 1.2.1	Theoretical Derivation

##### (I)	The Error Distribution Is Symmetrical

In the discussion below, we take data with packet size of 4 for example.

Define the probability of digit $a$ being sent at the transmitter as $Pr(Tx=a)$. Since the transmitted digits are uniformly distributed between the widest range, different numbers within the range have the same probability of occurring and let it be $P_0$. We can easily calculate that $Pr(Tx=0) = Pr(Tx=1) = \cdots = Pr(Tx=15) = P_0 = 1/16$.

Define the probability of data error $b$ when transmitting digit $a$ as $Pr(e=b\ |\ a)$ and the probability of data error $b$ in general is $Pr(e=b)$. According to Bayesian formula,
$$
Pr(e=b) = \sum\limits_{i=0}^{15} Pr(e=b\ |\ i)Pr(Tx=i) = \sum\limits_{i=0}^{15} Pr(e=b\ |\ i)P_0
$$
Obviously, if we send two digits that are 1's complement to each other, the error distribution at the receiving end is symmetrical because under our assumption, the probability of the receiver misclassifying bit 0 as bit 1 is equal to that of misclassifying bit 1 as bit 0. For example, number 0 and 15 are 1'scomplement to each other in binary format:  0000 and 1111. The possible data error that will occur when transmitting digit 0 can be $\{ 0, 1, 2, 3, \dots, 15 \}$ and the possible data error that will occur when transmitting digit 15 can be $\{ 0, -1, -2, \dots, -15 \}$. We can easily get that $Pr(e=+k\ |\ 0) = Pr(e=-k\ |\ 15)$ and it is the same with other digits with the same feature. The conclusion can be written as
$$
Pr(e = +k\ |\ a) = Pr(e = -k\ |\ \bar{a})
$$
where $\bar{a}$ represents 1's complement of digit $a$.

On this basis, we can summarize a law of data error distribution as
$$
Pr(e=+b) = \sum\limits_{i=0}^{15} Pr(e=+b\ |\ i)P_0 = \sum\limits_{i=0}^{15} Pr(e=-b\ |\ \bar{i})P_0 = \sum\limits_{i=0}^{15} Pr(e=-b\ |\ 15-i)P_0 = Pr(e=-b) \\ \\
\Rightarrow\quad Pr(e=+b) = Pr(e=-b)
$$
The derivation above proves the first half of the conclusion presented earlier, while the second half of the conclusion is obvious.

If we set a different transmit power for each bit in a packet individually, we can get different bit error probability for different bits. Let us suppose the bit error probabilities for different bit in a packet of 4 are $Pe_1, Pe_2, Pe_3, Pe_4$ and the probability of data error 0 should be
$$
Pr(e=0) = \prod\limits_{i=1}^4(1-Pe_i)
$$
In a general communication system, unless the signal-to-noise ratio is extremely low, in most cases, the bit error probability or BER (bit error rate) are not too large, normally much less than 1. Therefore, the value of the expression above is very close to one in a high SNR case and at least larger than the probability of other data error in most cases.

##### Conclusion 1.1	The distribution of data errors is symmetric about zero, with the peak at zero point.

$$
\begin{align}
&Pr(e=+b) = Pr(e=-b) \tag{1.1.1} \\ \\
&\max\limits_b \{ Pr(e=b) \} = Pr(e=0) \tag{1.1.2} \\ \\
&(b = 0,1,2,\dots,2^{Np}-1)
\end{align}
$$

where $Np$ is the number of bits in a packet.

##### (II)	Expression of The Error Distribution

In this section, we try to derive a general expression of the error distribution for packet size $Np$.

According to the conclusion above
$$
Pr(e=0) = \prod\limits_{i=1}^{Np}(1-Pe_i)
$$
For the cases where the data error is 1, we know that when sending an even number of digits, only the last bit needs to be in error. In other cases when sending digit is even, at least two bits need to be in error. The probability of only the last bit to be in error is $Pr_1 = (1-Pe_{Np}) \dot\ (1-Pe_{Np-1}) \cdots (1-Pe_2) \dot\ Pe_1$ and since $Pe < 0.5 < 1-Pe$, the maximal probability of at least two bit to be in error is $Pr_2 = (1-Pe_{Np}) \dot\ (1-Pe_{Np-1}) \cdots (1-Pe_3) \dot\ Pe_2 \dot\ Pe_1$. As we has been discussed above, normally the bit error probability $Pe_1, Pe_2 \ll 0.5$. So, $Pr_1 \gg Pr_2$. In the value range $[0,2^{Np}-1]$, the number of digits whose last bit are 0 is $2^{Np-1}$, half of the total number of valid digits.



#### 1.2.2	Simulation

All the experiments below is based on the baseband equivalent system model.

<img src="./figures/system_struct.svg" alt="figure-1-1" style="zoom:25%;" />

##### (1)	Experimental on the effect of adjusting the transmitting power on the data error distribution

| Channel model | AWGN 			|
| :-----------: | :-----------: |
|  |      			|





To look into the error distribution for different transmitted data, a MATLAB simulation is conducted. The simulation results show that for different transmit digits, the main distribution points of the reception error are determined by different major bits. The finding is not surprising as we know different bits have different weights when converting a binary number to decimal.

So the problem is how to take advantage of this feature to make the received data error a random distribution.

### 1.2 Example

For example, if we want to transmit number $2$ with package size 4 and the transmission error mainly distributed in the range $[-2,2]$. Here we can make a simple representation of the error distribution
$$
(2)_{10} \Rightarrow (0010)_2 \Rightarrow \left\{
\begin{align}
&0000 \rightarrow P(e=-2) = (1-p_1)(1-p_2)p_3(1-p_4) \\
&0001 \rightarrow P(e=-1) = (1-p_1)(1-p_2)p_3p_4 \\
&0010 \rightarrow P(e=+0) = (1-p_1)(1-p_2)(1-p_3)(1-p_4) \\
&0011 \rightarrow P(e=+1) = (1-p_1)(1-p_2)(1-p_3)p_4 \\
&0100 \rightarrow P(e=+2)=(1-p_1)p_2(1-p_3)(1-p_4) \\
\end{align}
\right.
$$
In the real situation, transmission BER is normally very low if $\frac{E_b}{N_0}$ is not too small, which means, in the example above, $P(e=-2),P(e=+2)$ and $P(e=-1),P(e=+1)$ would vary largely. Thus, the distribution of transmission error would be irregular and hard to calculate a suitable power distribution scheme.

### 1.3	Simulation of Power Allocation

To figure out how the allocation of power influence data error in transmission, we can reduce the transmission power of different bits in one pack. Let us start from the lowest bit. 

(1)	Reduce the power of last bit (LSB) to $1/2$, $1/4$ and $1/8$, the received error distribution vary, but, in general, we can find that interference exists only between two adjacent bits.

(2)	Move on to reduce the tx power of the bits followed, the data error distribution range is then expanded.