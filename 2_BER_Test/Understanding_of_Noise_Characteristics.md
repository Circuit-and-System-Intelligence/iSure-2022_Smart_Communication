# Understanding of Noise Characteristics

## 1	Noise Indicators

### 1.1	$$SNR$$

​	(1)	Description: Signal-to-Noise Ratio

​	(2)	Formula:
$$
SNR = \frac{P_{signal}}{P_{noise}}
$$
​	(3)	Example: for signal average power $P$ and zero-mean gaussian noise with variance $\sigma^2$
$$
SNR_{example} = \frac{P}{\sigma^2}
$$

### 1.2	$E_b/N_0$	and	$E_s/N_0$

​	(1)	Description: $E_b$ represents the average energy of a bit, $E_s$ represents the average energy of a symbol, $N_0$ represents noise power spectrum density

​	(2)	Conversion formula
$$
E_s/N_0(dB) = E_b/N_0(dB) + 10\ \mathrm{log}_{10}(k)
$$
​	where k is the number of information bits per symbol

​	(3)	Practical example
$$
Source\ (E_b) \to Source\ Encode\ (E_b^\prime) \to Channel\ Encode\ (E_b^{\prime\prime}) \to Modulation\ (E_s)
$$

$$
E_b = S*T_{samp}
$$

​	where $S$ represents signal power

​	Assume signal source encoding efficiency is $\eta_1$ and channel encoding efficiency is $\eta_2$
$$
E_b^{\prime} = \eta_1*E_b \\ \\
E_b^{\prime\prime} = \eta_2*E_b^\prime = \eta_1*\eta_2*E_b
$$
​	Assume modulation order is $M$
$$
E_s = \mathrm{log_2}M * E_b^{\prime\prime} =  \mathrm{log_2}M * \eta_1*\eta_2*E_b
$$

### 1.3	Relationship

#### 1.3.1	Complex Signal

$N_0$ is the single-sided noise spectrum density.

The average power of signal is
$$
P_S = \frac{E_s}{T_{sym}}
$$
Assume single-sided noise power spectrum density is $N_0$, then noise average power is
$$
P_N = N_0*F_s = \frac{N_0}{T_{samp}}
$$
Thus, the signal-to-noise ratio can be calculated as
$$
SNR = \frac{P_S}{P_N} = \frac{E_S/N_0}{T_{sym}/T_{samp}}
$$
Expressed in dB
$$
SNR\ (dB) = 10\ \mathrm{log_{10}}\Big( \frac{T_{samp}}{T_{sym}} \Big) + \frac{E_s}{N_0}\ (dB) \\ \\
\frac{E_s}{N_0}\ (dB) = 10\ \mathrm{log_{10}}\Big( \frac{T_{sym}}{T_{samp}} \Big) + SNR\ (dB)
$$
Since the discussion is based on complex signal and channel coefficient, the noise is also complex
$$
n(m) = n_I(m) + j\ n_Q(m) \\ \\
n_I(m) \sim N \Big( 0,\frac{P_N}{2} \Big),\quad n_Q(m) \sim N \Big( 0,\frac{P_N}{2} \Big)
$$

#### 1.3.2	Real Signal

$\frac{N_0}{2}$ is the double-sided noise spectrum density.
$$
P_N = \frac{N_0}{2}*2F_s = \frac{N_0}{T_{samp}}
$$
Thus, we can calculate that
$$
SNR\ (dB) = 10\ \mathrm{log_{10}}\Big( \frac{T_{samp}}{T_{sym}} \Big) + \frac{E_s}{N_0}\ (dB) \\ \\
\frac{E_s}{N_0}\ (dB) = 10\ \mathrm{log_{10}}\Big( \frac{T_{sym}}{T_{samp}} \Big) + SNR\ (dB)
$$

## 2	Application

### 2.1	Simplest Model

First, we assume there is no upsampling and encoding, which indicates that  $T_{samp}=T_{sym}$. So the signal-to-noise ratio is simplified for complex signal
$$
SNR = \frac{E_s}{N_0}\ (Watt)
$$
And for real signal
$$
SNR = \frac{E_s}{N_0}\ (Watt)
$$


#### 2.1.1	AWGN Channel with BPSK Modulation

Let the transmission symbol be $x = \pm a$. So $P_S = a^2$ and the noise power can be calculated
$$
\sigma^2 = \frac{a^2}{SNR}\ (Watt)
$$
Baseband shaping process makes no difference to BER-SNR characteristic because SNR only focuses on the signal bits that carries valid information.

The theoretical BER is
$$
BER_{AWGN-BPSK} = Q \big( \sqrt{SNR}\ \big)
$$


#### 2.1.2	Rayleigh Fading Channel with BPSK Modulation

Similarly, the transmission symbol is $x = \pm a$ and $P_S = a^2$.

However, the channel coefficients are complex signals. So, the additive white gaussian noise should be complex, too. Its real and image part both obey gaussian distribution with power $\sigma^2$. Thus, the total noise power should be $2\sigma^2$. But the transmitted signal is in real form, so when we calculate $SNR$, we should only consider the in-phase component of gaussian noise.
$$
\sigma^2 = \frac{a^2}{SNR}\ (Watt)
$$
