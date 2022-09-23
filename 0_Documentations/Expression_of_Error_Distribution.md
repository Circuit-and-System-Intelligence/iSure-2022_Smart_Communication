# Expression of Error Distribution

## 1	Bit Error Probability

Define the bit error probability as $p_e$. At the transmission end, uniformly distributed data is transmitted, the probability of transmitting 0 and 1 is both 1/2. Thus, at the receiving end, the error could be -1, 0, 1 and their occurrence probability are as follows.
$$
\begin{align}
&P(e = -1) = \frac{1}{2}p_e \\
&P(e = 0) = \frac{1}{2}(1-p_e) + \frac{1}{2}(1-p_e) = 1-p_e \\
&P(e = 1) = \frac{1}{2}p_e
\end{align}
$$

## 2	Transmit in A Pack

### 2.1	Explanation for Some Random Variables

$Ds$: Data sent

$Dr$: Data received

$De$: Data error

$S_i$: The $(i+1)th$ sent bit

$R_i$: The $(i+1)th$ received bit

$X_i$: The $(i+1)th$ error bit

### 2.2	Expression for Distribution

#### 2.2.1	Overview

Assume the system transmit data in a pack of $N_p$. The decimal format of transmitted and received data can be expressed by their binary format in the following way.
$$
Ds = 2^{N_p-1}S_{N_p-1} + 2^{N_p-2}S_{N_p-2} + \cdots + 2^1S_1 + 2^0S_0 \\
Dr = 2^{N_p-1}R_{N_p-1} + 2^{N_p-2}R_{N_p-2} + \cdots + 2^1R_1 + 2^0R_0
$$
Therefore, the data error can be expressed as
$$
\begin{align}
De &= Dr - Ds \\
&= 2^{N_p-1}(R_{N_p-1}-S_{N_p-1}) + 2^{N_p-2}(R_{N_p-2}-S_{N_p-2}) + \cdots + 2(R_1-S_1) + (R_0-S_0) \\
&= 2^{N_p-1}X_{N_p-1} + 2^{N_p-2}X_{N_p-2} + \cdots + 2X_1 + X_0
\end{align}
$$
For each bit, it follows the error probability derived in last section.
$$
P(X_i=x_i)=
\left\{
\begin{aligned}
&\frac{1}{2}p_{e_i}& ,\ &x_i=-1 \\
&1-p_{e_i}& ,\ &x_i=0 \\
&\frac{1}{2}p_{e_i}& ,\ &x_i=1
\end{aligned}
\right.
$$
Next, look at each term in the expression of $X_d$. Let $2^iX_i=Y_i$, then the expression of $e_d$ can be written as
$$
De = \sum\limits_{i=0}^{N_p-1}Y_i
$$

#### 2.2.2	Recursive Form of Expression

To rewrite the above equation into a recursive form, define $Z_k = \sum\limits_{i=0}^k Y_i$.
$$
\begin{align}
&Z_k = Z_{k-1} + Y_k, \quad (k \ge 1) \\
&Z_0 = Y_0
\end{align}
$$
The distribution of random variable $x_i$ can be derived as
$$
P(Y_i=y_i) =
\left\{
\begin{aligned}
&\frac{1}{2}p_{e_i}& ,\ &y_i=-2^i \\
&1-p_{e_i}& ,\ &y_i=0 \\
&\frac{1}{2}p_{e_i}& ,\ &y_i=2^i
\end{aligned}
\right.
$$
Since $X_i$ are independent, $Y_i$ are independent random variables.

According to the Convolution Theorem, the probability distribution of $Z_k$ can be written as
$$
\begin{align}
P(Z_k = z_k) &= \sum\limits_{l=-\infin}^{\infin}P(Y_k=l)P(Z_{k-1}=z_k-l) \\
&= \sum\limits_{l=-2^k,0,2^k} P(Y_k=l)P(Z_{k-1}=z_k-l) \\
&= \frac{1}{2}p_{e_k} \left[ P(Z_{k-1}=z_k+2^k) + P(Z_{k-1}=z_k-2^k) \right] + (1-p_{e_k})P(Z_{k-1}=z_k)
\end{align}
$$
To simplify the equation above, we first look at the valid value of random variable $Z_{k-1}$.
$$
Z_{k-1} \in \left\{ -2^k+1, -2^k+2, \dots, -1, 0, 1, \dots, 2^k-2, 2^k-1 \right\}
$$
From previous derivation, we have already known that the probability of any random variable $Z_i$ is symmetric about 0. Therefore, we only look at the probability of $Z_k \le 0$.

First, let us deal with the case when $z_k=0$, it can be simply written as
$$
P(Z_k=0) = (1-p_{e_k})(1-p_{e_{k-1}}) \cdots (1-p_{e_1})(1-p_{e_0}) = \sum\limits_{i=0}^k(1-p_{e_i})
$$
Then it comes to the case when $Z_k \le 0$. Since $z_k-2^k \le -2^k < -2^k+1$, then $P(Z_{k-1}=z_k-2^k) = 0$. The minimal valid value of $Z_k$ satisfies the equation $z_k+2^k = -2^k+1$, i.e., $z_k = -2^{k+1}+1$.

From the above derivation, it can be verified that: when $-2^{k+1}+1 \le z_k \le -1$, $P(Z_{k-1}=z_k-2^k) > 0$; when $z_k \le -2^{k+1}$, $P(Z_{k-1}=z_k-2^k) = 0$.

And what about the term $P(Z_{k-1}=z_k)$? Apparently, when $z_k \le -2^k$, $P(Z_{k-1}=z_k) = 0$; when $-2^k+1 \le z_k \le -1$, $P(Z_{k-1}=z_k) > 0$.

So, the probability distribution of $Z_k$ can be written as
$$
P(Z_k = \pm z_k)=
\left\{
\begin{aligned}
&\frac{1}{2}p_{e_k}P(Z_{k-1}=z_k+2^k)& &,\ -2^{k+1}+1 \le z_k \le -2^k \\
&\frac{1}{2}p_{e_k}P(Z_{k-1}=z_k+2^k) + (1-p_{e_k})P(Z_{k-1}=z_k)& &,\ -2^k+1 \le z_k \le -1 \\
&\sum\limits_{i=0}^k(1-p_{e_i})& &,\ z_k=0
\end{aligned}
\right.
$$

Rewrite the formula using $z_k>0$ as variable
$$
P(Z_k = \pm z_k)=
\left\{
\begin{aligned}
&\frac{1}{2}p_{e_k}P(Z_{k-1}=z_k-2^k)& &,\ 2^k \le z_k \le 2^{k+1}-1 \\
&\frac{1}{2}p_{e_k}P(Z_{k-1}=z_k-2^k) + (1-p_{e_k})P(Z_{k-1}=z_k)& &,\ 1 \le z_k \le 2^k-1 \\
&\sum\limits_{i=0}^k(1-p_{e_i})& &,\ z_k=0
\end{aligned}
\right.
$$


#### 2.2.3	Partial Initial Values

For $k=0$, $Z_0=Y_0$
$$
P(Z_0 = \pm z_0) = 
\left\{
\begin{aligned}
&\frac{1}{2}p_{e_0}& ,\ &z_0=-1 \\
&1-p_{e_0}& ,\ &z_0=0
\end{aligned}
\right.
$$
For $k=1$, $Z_1=Z_0+Y_1$
$$
\begin{align}
P(Z_1 = \pm z_1) &= 
\left\{
\begin{aligned}
&\frac{1}{2}p_{e_1}P(Z_0=z_1+2)& ,\ &z_1=-3,-2 \\
&\frac{1}{2}p_{e_1}P(Z_0=z_1+2) + (1-p_{e_1})P(Z_0=z_1)& ,\ &z_1=-1 \\
&(1-p_{e_1})(1-p_{e_0})& ,\ &z_1=0
\end{aligned}
\right. \\ \\
&=
\left\{
\begin{aligned}
&\frac{1}{4}p_{e_1}p_{e_0}& ,\ &z_1=-3 \\
&-\frac{1}{2}p_{e_1}p_{e_0} + \frac{1}{2}p_{e_1}& ,\ &z_1=-2 \\
&-\frac{1}{4}p_{e_1}p_{e_0} + \frac{1}{2}p_{e_0}& ,\ &z_1=-1 \\
&(1-p_{e_1})(1-p_{e_0})& ,\ &z_1=0
\end{aligned}
\right.
\end{align}
$$
For $k=2$, $Z_2=Z_1+Y_2$
$$
\begin{align}
P(Z_2 = \pm z_2) &= 
\left\{
\begin{aligned}
&\frac{1}{2}p_{e_2}P(Z_1=z_2+4)& ,\ &z_2=-7,-6,-5,-4 \\
&\frac{1}{2}p_{e_2}P(Z_1=z_2+4) + (1-p_{e_2})P(Z_1=z_2)& ,\ &z_2=-3,-2,-1 \\
&(1-p_{e_2})(1-p_{e_1})(1-p_{e_0})& ,\ &z_2=0
\end{aligned}
\right. \\ \\
&=
\left\{
\begin{aligned}
&\frac{1}{8}p_{e_2}p_{e_1}p_{e_0}& ,\ &z_2=-7 \\
&-\frac{1}{4}p_{e_2}p_{e_1}p_{e_0} + \frac{1}{4}p_{e_2}p_{e_1}& ,\ &z_2=-6 \\
&-\frac{1}{8}p_{e_2}p_{e_1}p_{e_0} + \frac{1}{4}p_{e_2}p_{e_0}& ,\ &z_2=-5 \\
&\frac{1}{2}p_{e_2}p_{e_1}p_{e_0} - \frac{1}{2}p_{e_2}p_{e_1} - \frac{1}{2}p_{e_2}p_{e_0} + \frac{1}{2}p_{e_2}& ,\ &z_2=-4 \\
&-\frac{3}{8}p_{e_2}p_{e_1}p_{e_0} + \frac{1}{4}p_{e_2}p_{e_0} + \frac{1}{4}p_{e_1}p_{e_0}& ,\ &z_2=-3 \\
&\frac{1}{4}p_{e_2}p_{e_1}p_{e_0} - \frac{1}{4}p_{e_2}p_{e_1} - \frac{1}{2}p_{e_1}p_{e_0} + \frac{1}{2}p_{e_1}& ,\ &z_2=-2 \\
&\frac{3}{8}p_{e_2}p_{e_1}p_{e_0} - \frac{1}{2}p_{e_2}p_{e_0} - \frac{1}{4}p_{e_1}p_{e_0} + \frac{1}{2}p_{e_0}& ,\ &z_2=-1 \\
&(1-p_{e_2})(1-p_{e_1})(1-p_{e_0})& ,\ &z_2=0
\end{aligned}
\right.
\end{align}
$$

$$
P(Z_3 = \pm z_3) &= 
\left\{
\begin{aligned}
&\frac{1}{2}p_{e_3}P(Z_2=z_3+8)& ,\ &z_3=-15,-14,-13,-12,-11,-10,-9,-8 \\
&\frac{1}{2}p_{e_3}P(Z_2=z_3+8) + (1-p_{e_3})P(Z_2=z_3)& ,\ &z_3=-7,-6,-5,-4,-3,-2,-1 \\
&(1-p_{e_3})(1-p_{e_2})(1-p_{e_1})(1-p_{e_0})& ,\ &z_2=0
\end{aligned}
\right.
$$

