# Explanation for Formulas

## 1	System Structure

<center>
    <img style="border-radius: 0.3125em;
                box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);"
         src=".\image_for_documents\time_vary_channel_struct_iq.svg">
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
                display: inline-block;
                color: #999;
                padding: 2px;">Figure 1.1  Channel Model Frame</div>
</center>

## 2	Understanding of Time-Varying Channel Response

### 2.1	Time-Consistent System

Channel response is $h(\tau)$.

Given a unit impulse input at any time $t$, the response of the particular input at time $t+\tau$ is $h(\tau)$.

### 2.2	Time-Varying System

Channel response is $h(\tau,t)$.

Given a unit impulse input at time $t-\tau$, the response of the particular input at time $t$ is $h(\tau,t)$.

### 2.3	Put Channel Response into the System

To figure out the output signal's expression at any time $t$ : $r(t)$
$$
r(t) = \int_{-\infin}^{\infin} h(\tau,t)s(t-\tau)\ \mathrm{d}\tau \tag{2.1}
$$
For a causal system
$$
r(t) = \int_0^{\infin} h(\tau,t)s(t-\tau)\ \mathrm{d}\tau \tag{2.2}
$$

### 2.4	Formula Derivation

Considering multipath propagation, the received signal $y(t)$ can be written as the sum of multipath received signal
$$
r(t) = \sum\limits_i a_i(t) s(t-\tau_i(t)) \tag{2.3}
$$
where $a_i(t)$ stands for different path's gain and $\tau_i(t)$ stands for different path's delay, they are both time-varying.

Thus, the RF channel impulse response can be written as
$$
h(\tau,t) = \sum\limits_i a_i(t)\delta(\tau-\tau_i(t)) \tag{2.4}
$$

## 3	Baseband Equivalent Channel Impulse Response

### 3.1	General Description

The baseband equivalent channel impulse response is $h_b(\tau,t)$ in the graph in Section 1.

The purpose of introducing $h_b(\tau,t)$ is to skip up-conversion steps in order to complete simulation in a digital device.

### 3.2	Formula Derivation

Normally, modulated baseband signal can be decomposed into in-phase and quadrate signals
$$
x_b(t) = x_I(t) + jx_Q(t) \tag{3.1}
$$
Transmitted signal after up-conversion can be written as
$$
\begin{align}
s(t) &= x_I(t)\ \mathrm{cos}(2\pi f_c t) - x_Q(t)\ \mathrm{sin}(2\pi f_c t) \\ \\ 
&=\real[x_b(t)e^{j 2\pi f_c t}]
\end{align}
\tag{3.2}
$$
Add the RF transmitted signal to time-varying channel. According to formula (2.3) the received RF signal is
$$
\begin{align}
r(t) &= \sum\limits_i a_i(t)\cdot\real[x_b(t-\tau_i(t)) e^{j 2\pi f_c (t-\tau_i(t))}] \\ \\
&=\real\Big[\sum\limits_i a_i(t) x_b(t-\tau_i(t)) e^{j 2\pi f_c (t-\tau_i(t))}\Big]
\end{align}
\tag{3.3}
$$
Apply down-conversion and low-pass filter to recover baseband signal
$$
\begin{align}
\real[y_b(t)] &= r(t)\ \mathrm{cos}{2\pi f_c t} = \frac{1}{2}r(t)(e^{j 2\pi f_c t}+e^{-j 2\pi f_c t})\\ \\
&= \frac{1}{2}\real\Big[\sum\limits_i a_i(t) x_b(t-\tau_i(t)) e^{-j 2\pi f_c \tau_i(t)}\Big]
\end{align}
\tag{3.4}
$$
Similarly, we can obtain (the proof is omitted)
$$
\image[y_b(t)] = \frac{1}{2}\image\Big[\sum\limits_i a_i(t) x_b(t-\tau_i(t)) e^{-j 2\pi f_c \tau_i(t)}\Big] \tag{3.5}
$$
If all the carrier waves at both ends multiple $\sqrt{2}$, then the received baseband signal can be written as
$$
y_b(t) = \sum\limits_i a_i(t) x_b(t-\tau_i(t)) e^{-j 2\pi f_c \tau_i(t)} \tag{3.6}
$$
Thus, the baseband equivalent channel impulse response is
$$
h_b(\tau,t) = \sum\limits_i a_i(t) \delta(\tau-\tau_i(t)) e^{-j 2\pi f_c \tau_i(t)} \tag{3.7}
$$
We can find that, in the formula above, the sum stands for different paths, the first factor stands for **path gain**, the middle factor stands for **path delay**, the last factor stands for **doppler shift** in each path.

## 4	Discretization

### 4.1	General Description

To simulate the channel model in MATLAB, the parameters and functions should be discretized. The interpolation and sampling process is designed for that purpose. 

### 4.2	Interpolation

Normally, we exert orthogonal decomposition on discrete baseband signal
$$
x_b(n) = x_I(n) + jx_Q(n) \tag{4.1}
$$
According to sampling theorem
$$
x_b(t) = \sum\limits_m x_b(m)\ \mathrm{sinc}(F_st-m) \tag{4.2}
$$
where
$$
\mathrm{sinc}(t) := \frac{\mathrm{sin}(\pi t)}{\pi t}
$$
Assuming we have the same sampling rate at transmitter and receiver. Substitute parameters in formula (3.6) with formula (4.2) and discretize it 
$$
\begin{align}
y_b(n) &= \sum\limits_i a_i(\frac{n}{F_s})\ e^{-j 2\pi f_c\tau_i(\frac{n}{F_s})} \sum\limits_m x_b(m)\ \mathrm{sinc}(F_s(\frac{n}{F_s}-\tau_i(\frac{n}{F_s}))-m) \\ \\
&= \sum\limits_m x_b(m) \sum\limits_i a_i(\frac{n}{F_s})\ e^{-j 2\pi f_c\tau_i(\frac{n}{F_s})} \ \mathrm{sinc}(n-m-\tau_i(\frac{n}{F_s})F_s)
\end{align}
\tag{4.3}
$$
Similarly to continuous time-varying channel impulse response, we define delay as $l=n-m$, then
$$
y_b(n) = \sum\limits_l x_b(n-l) \sum\limits_i a_i(\frac{n}{F_s})\ e^{-j 2\pi f_c \tau_i(\frac{n}{F_s})}\ \mathrm{sinc}(l-\tau_i(\frac{n}{F_s})F_s) \tag{4.4}
$$
Thus, we can define discrete time-varying channel impulse response
$$
h_l(n) := \sum\limits_i a_i(\frac{n}{F_s})\ e^{-j 2\pi f_c \tau_i(\frac{n}{F_s})}\ \mathrm{sinc}(l-\tau_i(\frac{n}{F_s})F_s) \tag{4.5}
$$
The received baseband equivalent signal can be written as
$$
y_b(n) = \sum\limits_l h_l(n)x(n-l) \tag{4.6}
$$

## 5	Channel Characteristics

### 5.1	Coherence Time

According to formula (4.5), doppler shift for $i$th path is $f_c \tau_i$. Normally, there should be a path that has the biggest doppler shift, and a path that has the smallest doppler shift. Define doppler spread
$$
D_s = \mathop{max}_{i,j}\{f_c|\tau_i-\tau_j|\}
$$
It can be deduced that coherence time has the following relationship with doppler spread
$$
T_c \propto \frac{1}{D_s}
$$
$T_c$ can be described as the maximum time during which the channel coefficients remain unchanged. Define the interval between two symbols is $T$.

If $T<T_c$, then the channel is a slow fading channel, can be viewed as time-consistent.

If $T>T_c$, then the channel is a fast fading channel and is time-varying.

### 5.2	Coherence Bandwidth

Similarly, there should be a path that has the biggest time delay, and a path that has the smallest time delay. Define delay spread
$$
T_m = \mathop{max}_{i,j} \{ |\tau_i - \tau_j| \}
$$
It can be deduced that coherence bandwidth has the following relationship with delay spread
$$
B_c \propto \frac{1}{T_m}
$$
$B_c$ can be described as the maximum frequency range during which the channel coefficients remain unchanged. Define the bandwidth of baseband signal is $W$.

If $W<B$, then the channel is a flat fading channel, or frequency non-selective channel.

If $W>B$, then the channel is a frequency selective channel.

## 6	Frequency Non-selective Channel

### 6.1	Basic Principle

Rewrite the transmission formula (4.6) in frequency domain
$$
Y_b(f)=H_b(f;n)X_b(f) \tag{6.1}
$$
where $H(f;t)$ means the channel have different frequency response at different time.

For flat fading channel, the channel frequency response for transmitted baseband signal can be viewed as consistent. Thus, formula (6.1) can be simplified
$$
Y_b(f) = H_b(0;n)X_b(f) \tag{6.2}
$$
So it is appropriate to define
$$
h_b(n) := H_b(0;n)	\tag{6.3}
$$
So the transmission formula in time domain is
$$
y_b(n) = h_b(n)x_b(n)	\tag{6.4}
$$
This means current output at time $n$ is only determined by the input and channel impulse response at time $n$. The expression of $h_b(n)$ can be modified from formula (4.5)
$$
h(n) := \sum\limits_i a_i(\frac{n}{F_s})\ e^{-j 2\pi f_c \tau_i(\frac{n}{F_s})}\ \mathrm{sinc}(-\tau_i(\frac{n}{F_s})F_s)	\tag{6.5}
$$

Also, the convolution between input signal and channel impulse response can simply be replaced by multiple, like what is shown in the figure below

<center>
    <img style="border-radius: 0.3125em;
                box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);"
         src=".\image_for_documents\freq_nonsel_chan.svg">
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
                display: inline-block;
                color: #999;
                padding: 2px;">Figure 6.1  Simplified Transmission Model for Flat Fading Channel</div>
</center>

### 6.2	Rayleigh Fading Channel

According to large amount of experiments, $h(n)$ in formula (6.5) conforms to complex Gaussian distribution in time domain. Rewrite the fading channel coefficient in complex form
$$
\begin{align}
h(n) &= h_I(n) + jh_Q(n) \\ \\ 
&= \alpha(n)\ e^{j \phi(n)}
\end{align}
\tag{6.6}
$$
