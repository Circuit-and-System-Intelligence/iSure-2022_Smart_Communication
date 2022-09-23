# Baseband Demodulation and Detection

## 1	The Matched Filter

### 1.1	Definition

Receiver filter to get maximum $SNR$.

### 1.2	The Optimum Filter Transfer Function

$$
H_0(f) = kS^*(f)\mathrm{e}^{-\mathrm{j}2\pi fT} \\ \\
h(t) = ks(T-t),\quad 0\le t \le T
$$

where $s(t)$ is sending signal.
$$
\mathrm{max} \left( \frac{S}{N} \right)_T = \frac{2E}{N_0}
$$
where $E$ is the energy of input signal.

### 1.3	Correlation Realization

When $t=T$, the output of the MF $z(t)$ is the same as the result of correlation between $r(t)$ and $s(t)$.
$$
z(T) = \int_{0}^{T} r(\tau) s(\tau) \mathrm{d}\tau
$$

## 2	Optimizing Error Performance

### 2.1	Optimum Decision Threshold

Sample filtered received signal at time $T$
$$
z(T) = a_i(T) + n_0(T)
$$
The corresponding error is
$$
P_B = Q \left( \frac{a_1-a_2}{2\sigma_0} \right)
$$

### 2.2	Considering Matched Filter

$$
P_B = Q \left( \sqrt{\frac{E_d}{2N_0}} \right) = Q \left( \sqrt{\frac{E_b(1-\rho)}{N_0}} \right)
$$

where $\rho$ is the similarity between two signals
$$
\rho = \frac{1}{E_b}\int_{0}^{T} s_1(t) s_2(t)\mathrm{d}t = \mathrm{cos}\theta
$$
For example, for BPSK modulation with sending signal being $\pm a$, $\theta = \pi$
$$
P_B = Q \left( \sqrt{\frac{2E_b}{N_0}} \right)
$$

## 3	Inter-symbol Interference

### 3.1	The Nyquist Filter

The transmitting filter, channel filter and receiving filter altogether forms a transmission function for signal
$$
H(f) = H_t(f)H_c(f)H_r(f)
$$
Ignoring the channel filter the ideal transmission filter is the ideal Nyquist filter, whose spectrum is a rectangular window and impulse response is expressed by $\mathrm{sinc}$ function, but it is not physically realizable.

### 3.2	The Raised-Cosine Filter