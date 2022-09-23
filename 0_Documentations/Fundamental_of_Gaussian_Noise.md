# Gaussian Noise in Digital Communication

Zhiyu Shen	2022.08.06

## 1	Scalar Real Gaussian Random Variable

### 1.1	PDF

$$
f(x) = \frac{1}{\sqrt{2\pi}\sigma^2}e^{-\frac{(x-\mu)^2}{2\sigma^2}}
$$

Tail function $Q(x)$.

### 1.2	Property

If $x_i \sim \mathcal{N}(\mu_i,\sigma_i^2)$, then
$$
\sum\limits_{i=1}^n c_ix_i \sim \mathcal{N}(\sum\limits_{i=1}^n c_i\mu_i, \sum\limits_{i=1}^n c_i^2\sigma_i^2)
$$

## 2	Real Gaussian Random Vector

### 2.1	Standard Gaussian Random Vector

#### 2.1.1	PDF

If $\boldsymbol{w} = (w_1, w_2, \dots, w_n)^\top$, $w_i \sim \mathcal{N}(0, 1)$ (i.i.d), then define $\boldsymbol{w} \sim \mathcal{N}(\boldsymbol{0, I})$
$$
f(\boldsymbol{w}) = \frac{1}{(\sqrt{2\pi})^n}e^{-\frac{\Vert \boldsymbol{w} \Vert^2}{2}}
$$

#### 2.1.2	Properties

(1)	If $\boldsymbol{w}$ is **standard Gaussian random vector** and $\boldsymbol{O}$ is **orthogonal matrix**, then $\boldsymbol{O} \vec{w}$ is also **standard Gaussian random vector** and has the same distribution.

$\Rightarrow$ Standard Gaussian random vector's projection in orthogonal directions is independent

(2)	$\Vert \boldsymbol{w} \Vert^2$ obeys $\chi_n^2$ distribution

$\Rightarrow$ when $n=2$, it is a exponential distribution

### 2.2	Gaussian Random Vector

#### 2.2.1	Definition

$$
\boldsymbol{x} = \boldsymbol{Aw+\mu}
$$

#### 2.2.2	Properties

(1)	For any vector $\boldsymbol{c}$
$$
\boldsymbol{c^\top}\boldsymbol{x} \sim \mathcal{N}(\boldsymbol{c^\top\mu}, \boldsymbol{c^\top A  A^\top c})
$$
Linear transformation of Gaussian random vector is also Gaussian.

(2)	If $\boldsymbol{A}$ is invertible, then
$$
f(x) = \frac{1}{(\sqrt{2\pi})^n\sqrt{\vert \boldsymbol{AA^\top} \vert}} e^{-\frac{\boldsymbol{(x-\mu)^\top(AA^\top)^{-1}(x-\mu)}}{2}}
$$
And $\boldsymbol{AA^\top}$ is covariance matrix of $\boldsymbol{x}$
$$
\boldsymbol{K} = \mathop{E}[(\boldsymbol{x-\mu}) (\boldsymbol{x-\mu})^\top] = \boldsymbol{AA^\top}
$$
(3)	If $\boldsymbol{w}$ **standard Gaussian random vector** and $O$ is **orthogonal matrix**, then $\boldsymbol{Aw}$ and $\boldsymbol{AOw}$ obey the same distribution.

(4)	When $\boldsymbol{K}$ is a diagonal matrix, variables $x_i$ are independent (i.i.d), and it is called **white Gaussian random vector**.

(5)	When $\boldsymbol{K}$ is a identity matrix, variables $x_i$ are independent (i.i.d) and variance is 1, it is simplified as **standard Gaussian random vector**.

## 3	Complex Gaussian Random Vector

### 3.1	Definition and Properties

$$
\boldsymbol{x} = \boldsymbol{x}_R + j \boldsymbol{x}_I
$$

It has mean vector $\boldsymbol{\mu}$, covariance matrix $\boldsymbol{K}$, pseudo-covariance matrix $\boldsymbol{J}$.
$$
\begin{align}
\boldsymbol{\mu} &= \mathop{E}[\boldsymbol{x}] \\ \\
\boldsymbol{K} &= \mathop{E}[(\boldsymbol{x-\mu})(\boldsymbol{x-\mu})^*] \\ \\
\boldsymbol{J} &= \mathop{E}[(\boldsymbol{x-\mu})(\boldsymbol{x-\mu})^\top]
\end{align}
$$
But here the covariance matrix $\boldsymbol{K}$ cannot determine all the second-order statistics of $\boldsymbol{x}$.

### 3.2	Circular Symmetry Vector

#### 3.2.1	Definition

Circular symmetry property: $\boldsymbol{x}$ is circular symmetry if **$e^{j\theta}\boldsymbol{x}$ has the same distribution of $\boldsymbol{x}$ for any $\theta$.**

#### 3.2.2	Properties

(1)	Mean $\mu = \mathop{E}[\boldsymbol{x}] = 0$

(2)	Pseudo-covariance matrix $\boldsymbol{J} = \mathop{E}[\boldsymbol{xx}^\top] = 0$

(3)	Covariance matrix $\boldsymbol{K}$ fully specifies the first- and second-order statistics of $\boldsymbol{x}$.

### 3.3	Circular Symmetry Gaussian Vector

#### 3.3.1	Definition

If $\boldsymbol{x}$ is circular symmetry Gaussian vector, $\boldsymbol{K}$ specifies its entire statistics. 

$\boldsymbol{x}$ is denoted as $\mathcal{CN}(0,\boldsymbol{K})$

#### 3.3.2	Properties

(1)	Circular symmetry Gaussian random variable $w = w_R + jw_I$ must have i.i.d zero-mean real and imaginary component:

a.	The phase of $w$ is uniform over the range $[0, 2\pi]$

b.	The magnitude of $w$ is Rayleigh distributed

c.	Phase and magnitude is independent

d.	The square of the magnitude $w_R^2+w_I^2$ is $\chi_2^2$ distributed

(2)	A collection of $n$ i.i.d $\mathcal{CN}(0,1)$ variables forms a standard circular symmetric Gaussian random vector $\boldsymbol{w}$.

a.	The density function can be written as
$$
f(\boldsymbol{w}) = \frac{1}{\pi^n}e^{-\Vert \boldsymbol{w} \Vert^2}
$$
b.	If $\boldsymbol{w}$ is  circular symmetric Gaussian random vector and $\boldsymbol{U}$ is **unitary matrix**, then $\boldsymbol{U}\vec{w}$ has the same distribution as $\boldsymbol{w}$.

## 4	Gaussian Noise in Channel

![image - 202208081527](E:\1_Study\1_Projects\2_iSURE-project\2_Working\Task_6_20220809\figure_for_documentation\system_struct.svg)

### 4.1	Continuous-Time Model

Noise in analog channel is $w(t)$. It is a white Gaussian random process and it's spectrum density is $\frac{N_0}{2}$. The received continuous-time signal can be written as
$$
y(t) = \sum\limits_i a_i(t)x(t-\tau_i(t)) + w(t)
$$

### 4.2	Discrete-Time Baseband-Equivalent Model

White noise $w(t)$ is down-converted, filtered and ideally sampled.
$$
y(n) = \sum\limits_lh_l(n)x(n-l) + w(n)
$$
It can be verified that
$$
\real \big[ w(n) \big] = \int_{-\infin}^{\infin}w(t)\psi_{m,1}(t)\ \mathrm{d}t \\ \\
\image \big[ w(n) \big] = \int_{-\infin}^{\infin}w(t)\psi_{m,2}(t)\ \mathrm{d}t
$$
where
$$
\psi_{m,1}(t) := \sqrt{2W}\ \mathrm{cos}(2\pi f_ct)\ \mathrm{sinc}(Wt-m) \\ \\
\psi_{m,1}(t) := -\sqrt{2W}\ \mathrm{sin}(2\pi f_ct)\ \mathrm{sinc}(Wt-m)
$$
It is apparent that  $\{ \psi_{m,1}(t), \psi_{m,2}(t) \}_m$ is a standard orthogonal set and $w(t)$ can be seen as a infinite dimension Gaussian random vector. So the real and image component of discrete-time noise $w(n)$ can be seen as the projection of Gaussian random vector on a orthogonal set. They are both white Gaussian variable with variance $\sigma^2 = \frac{N_0}{2}$. Thus, $w(n)$ is verified as circular symmetry complex Gaussian variable, $w(n) \sim \mathcal{CN}(0,N_0)$.

## 5	Indicator of Signal-to-Noise Ratio in Digital Communication

Normally, in digital communication systems, we use $\frac{E_b}{N_0}$ to replace $\frac{S}{N}$ that is used in analog system. The relationship between the two indicators is as follows
$$
\frac{E_b}{N_0} = \frac{ST_b}{N/W} = \frac{S}{N} \bigg( \frac{W}{R} \bigg)
$$
where $R$ and $W$ are the bitrate and the bandwidth of baseband signal.

The most important measurement of a digital communication system is the $P_B - E_b/N_0$ curve.
