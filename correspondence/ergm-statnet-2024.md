# Upgrading an ERGM from v3.10 to v4.6

Correspondence with the statnet developers, May to December 2024, on why a fit that
converged under `ergm` 3.10 would not converge under 4.6, and which controls to change.
This is the source behind `R/control-settings.md` and the tuning discussion in Modules 3 to 5.

Reconstructed from the original thread. Email addresses and signature blocks have been
removed, along with messages carrying no technical content (see the end of this file).
The `statnet_help` list is publicly archived at
<http://mailman13.u.washington.edu/mailman/listinfo/statnet_help>.

---

## Aditya Khanna

*Thu, May 16, 2024 at 8:22 PM*

Dear Statnet Dev and User Community:

I have an ERGM that I fit previously with ERGM v3.10.4 on a directed network with 32,000 nodes. The model included in- and out-degrees, in addition to other terms. The complete Rout from this fit can be seen [here](https://gist.github.com/khanna7/aefd836baf47463051439c9e72764388). I am now trying to reproduce this fit with ergm v4.6, but the model does not converge. (See [here](https://gist.github.com/khanna7/fbabdde53c79504dfeaebd215bb5ee20).)

I am looking for ideas on how to trouble shoot this. One suggestion I got was to set values for the "tuning parameters" in the v4.6 to their defaults from v3.11.4. But ERGM v4.6 has a lot more parameters that can be specified, and I am not sure which ones make most sense to consider.

I would be grateful for any suggestions on this or alternate ideas to try.

Many thanks,

Aditya

## Carter T. Butts

*Fri, May 17, 2024 at 12:02 AM*

Hi, Aditya -

I will defer to the mighty Pavel for the exact best formula to reproduce 3.x fits with the latest codebase. (You need to switch convergence detection to "Hotelling," and there are some other things that must be modified.) However, as a general matter, for challenging models where Geyer-Thompson-Hummel has a hard time converging (particularly on a large node set), you may find it useful to try the stochastic approximation method (main="Stochastic" in your control argument will activate it). G-T-H can (in principle) have sharper convergence when near the solution, but in practice SA fails more gracefully. I would suggest increasing your default MCMC thinning interval (MCMC.interval), given your network size; depending on density, extent of dependence, and other factors, you may need O(N^2) toggles per step. It is sometimes possible to get away with as few as k*N (for some k in, say, the 5-100 range), but if your model has substantial dependence and is not exceptionally sparse then you will probably need to be in the quadratic regime. One notes that it can sometimes be helpful when getting things set up to run "pilot" fits with the default or otherwise smaller thinning intervals, so that you can discover if e.g. you have a data issue or other problem before you spend the waiting time on a high-quality model fit.

To put in the obligatory PSA, both G-T-H and SA are simply different strategies for computing the same thing (the MLE, in this case), so both are fine - they just have different engineering tradeoffs. So use whichever proves more effective for your model and data set.

Hope that helps,

-Carter

https://urldefense.com/v3/__http://mailman13.u.washington.edu/mailman/listinfo/statnet_help__;!! CzAuKJ42GuquVTTmVmPViYEvSg!KsbhvmLlx8TkLK7y2NKz59hK4-4H7KXVV7dEyUG4vcQzi4Mh7nO-

9HupA7_ep2V2p9KkD_i00tcg6nDqczDwObRNh35k$

## Aditya Khanna

*Fri, Aug 30, 2024 at 12:43 AM*

Hi Carter and All,

Thank you so much for the helpful guidance here. I think following your suggestions has brought us very close to reproducing the target statistics in the simulated networks, but there are still some gaps.

Our full previous exchange is below, but to summarize: I have an ERGM that I fit previously with ERGM v3.10.4 on a directed network with 32,000 nodes. The model consisted of in- and out-degrees in addition to other terms, including a custom distance term. In trying to reproduce this fit with ergm v4.6, the model did not initially converge. Your suggestion to try setting the main.method = “Stochastic Approximation” considerably improved the fitting. Specifying the convergence detection to “Hotelling” on top of that brought us almost to simulated networks that capture all the mean statistics. (Following an old [discussion thread](https://github.com/statnet/ergm/issues/346) on the statnet github, I also tried setting the termination criteria to Hummel and MCMLE.effectiveSize = NULL. I think, for me, in practice, Hotelling worked a bit better than Hummel though). In general, I tried fitting the model with variants of this specification. I got the best results with setting both MCMC samplesize=1e6 and interval = 1e6 (see table below).

| MCMC interval | MCMC sample size | Convergence detection | Results/outcome | Note |
|---|---|---|---|---|
| 1e6 | 1e6 | Hotelling | Closest agreement between simulated and target statistics | [Max. Lik. fit summary and simulation Rout](https://github.com/hepcep/net-ergm-v4plus/commit/777bae726d29dae969f06e0d17b40ee59a01a7fc); [violin plots showing the simulated and target statistics for each parameter](https://github.com/hepcep/net-ergm-v4plus/tree/main/fit-ergms/out) |

But, I found that this was the closest I could get producing simulated statistics that matched the target statistics. In general, any further increasing or decreasing of either the samplesize or interval did not help generate a closer result, i.e., this looked to be some optimum in the fit parameter space. I can provide further details on the results of those fits, which for some configurations didn’t converge, and if they did converge, the goodness-of-fit was worse than what I had with setting the MCMC interval and samplesize to 1e6. Based on your experiences, I was wondering if this is expected? For now, my main question is, are there any suggestions on how I can further tune the fitting parameters to match my targets more closely? I can provide specific details on the outcomes of those fitting processes if that would be helpful. Thanks for your consideration.

Aditya

## Carter T. Butts

*Fri, Aug 30, 2024 at 2:07 PM*

Hi, Aditya -

I'll be interested in Pavel's take on the convergence issues, but just to verify, you are assessing convergence based on a second MCMC run, correct? The MCMC statistics in the ergm object are from the penultimate iteration, and may thus be out of equilibrium (but this does not necessarily mean that the model did not converge). However, if you simulate a new set of draws from the fitted model and the mean stats do not match, then you have an issue. (This is why we now point folks to gof() for that purpose.) It looks like your plots are from the ergm object and not from a gof() run (or other secondary simulation), so I want to verify that first.

I also note that a quick glance at the plots from your more exhaustive simulation case don't seem all that far off, which could indicate either that the model did converge (and per above, we're not looking at a draw from the final model), or that it converged within the tolerances that were set, and you may need to tighten them. But best to first know if there's a problem in the first place.

Another observation is that, per my earlier email, you may need O(N^2) toggles per draw to get good performance if your model has a nontrivial level of dependence. You are using a thinning interval of 1e6, which is in your case around 30*N. It's possible that you've got too much dependence for that: O(N^2) here would mean some multiple of about 1e9, which is about a thousand times greater than what you're using. Really large, sparse networks sometimes can be modeled well without that much thinning, but it's not a given. Relatedly, your trace plots from the 1e6 run suggest a fair amount of autocorrelation on some statistics, which suggests a lack of efficiency. (Autocorrelation by itself isn't necessarily a problem, but it means that your effective MCMC sample size is smaller than it seems, and this can reduce the effectiveness of the MCMCMLE procedure. The ones from the 1e6 run aren't bad enough that I would be alarmed, but if I were looking for things to tighten up and knew this could be a problem, they suggest possible room for improvement.) So anyway, I wouldn't crank this up until verifying that it's needed, but you are still operating on the low end of computational effort (whether it seems like it or not!).

Finally, I would note that for the stochastic approximation method, convergence is to some degree (and it's a bit complex) determined by how many subphases are run, and how many iterations are used per subphase. This algorithm is due to Tom in his classic JoSS paper (but without the complement moves), which is still a good place to look for details. It is less fancy than some more modern algorithms of its type, but is extremely hard to beat (I've tried and failed more than once!). In any event, there are several things that can tighten that algorithm relative to its defaults, including increasing thinning, increasing the iterations per subphase, and increasing the number of subphases. Some of these sharply increase computational cost, because e.g. the number of actual subphase iterations doubles (IIRC) at each subphase - so sometimes one benefits by increasing the phase number but greatly reducing the base number of iterations per phase. The learning rate ("SA.initial.gain") can also matter, although I would probably avoid messing with it if the model is well- behaved (as here). I will say that, except under exotic conditions in which I am performing Unspeakable ERGM Experiments (TM) of which we tell neither children nor grad students, I do not recall ever needing to do much with the base parameters - adjusting thinning, as needs must, has almost always done the trick. Still, if other measures fail, tinkering with these settings can/will certainly affect convergence.

I'd check on those things first, and then see if you still have a problem....

Hope that helps,

-Carter

## Steven M. Goodreau

*Fri, Aug 30, 2024 at 9:09 PM*

Replying just to you two to thank you for all of your work and insight on this, as I feel like I have a much clearer sense and many more tools in my own arsenal now just from reading this.

Happy weekend!

Steve

## Aditya Khanna

*Fri, Sep 6, 2024 at 1:27 AM*

Hi Carter,

Thank you so much for your helpful response as always. I have organized my report in terms of the various things you suggest.

Verifying MCMC, GOF and the “second” MCMC: Yes, the ERGM for the model described below does converge, but, despite having converged, the simulated networks don’t seem to statistically capture the targets. I did make the GOF plots as well. Most of the terms look good, though some have peaks that are off from the zero. In general, however, I have come to rely more on actually simulating networks from the fitted ERGM object (what I think you mean by “second MCMC run”) in addition to the GOF plots. Usually I consider my goal fulfilled if the simulated network objects capture the targets, even if the GOF plots don’t look perfect.

Model Convergence and tightening the MCMC tolerances: In terms of tightening the MCMC tolerances, I did increase the MCMC interval to 1e9, of the order of O(N^2). But this particular specification timed out after 120 hours, and I didn’t try to run it for longer time than that.

Alternate parameters to tighten the MCMC: I have experimented with the MCMC sample size and interval parameters, but have not been able to improve the quality of the simulated network. I am not as familiar with what options are available within the bounds of some reasonable computational cost.

In summary, the problem remains that despite the ERGM convergence, the quality of the simulated networks suggests room for improvement, since the specified targets are not captured within the distribution of the simulated networks. Aditya

## Pavel Krivitsky

*Sat, Sep 7, 2024 at 5:30 PM*

Hi, Aditya,

Apologies for the slow reply. I have a quick question: have you tried running ergm() without overriding any of the control parameters? I.e., just let the adaptive code try to figure things out? Or, it might be worth overriding just the SAN controls, since those aren't adaptive.

Best,

Pavel

## Carter T. Butts

*Sun, Sep 8, 2024 at 5:58 AM*

Hi, Aditya -

On 9/5/24 12:57 PM, Khanna, Aditya wrote:

Hi Carter,

Thank you so much for your helpful response as always. I have organized my report in terms of the various things you suggest.

Verifying MCMC, GOF and the “second” MCMC: Yes, the ERGM for the model described below does

converge, but, despite having converged, the simulated networks don’t seem to statistically capture the targets. I did make the GOF plots as well. Most of the terms look good, though some have peaks that are off from the zero. In general, however, I have come to rely more on actually simulating networks from the fitted ERGM object (what I think you mean by “second MCMC run”) in addition to the GOF plots. Usually I consider my goal fulfilled if the simulated network objects capture the targets, even if the GOF plots don’t look perfect.

There seems to be some confusion here: setting aside exotica, if your mean in-model statistics don't match your observed in-model statistics, then your model has not converged. The matching here that matters is from an MCMC run from the fitted model, which is what the gof() function does (but this is not what you get from MCMC diagnostics on the fitted ergm() object, which should show the penultimate run - those are handy for diagnosing general MCMC issues, but need not show convergence even when the final coefficients yield a convergent model). The plots you linked to under "GOF" above seem to be MCMC diagnostics from an ergm() object, not gof() output. I'll come back to "exotica" below, but first it is important to be sure that we are discussing the same thing.

Model Convergence and tightening the MCMC tolerances: In terms of tightening the MCMC tolerances, I did increase the MCMC interval to 1e9, of the order of O(N^2). But this particular specification timed out after 120 hours, and I didn’t try to run it for longer time than that.

Unfortunately, there's no "that's longer than I want it to be" card that convinces mixing to happen more quickly: if your model is really going to take 1e9 or more updates per step to converge, and if that takes longer than 120 hours on your hardware, then that's how long it's going to take. If there were magic sauce that could guarantee great convergence with minimal computational effort every time, it would already be in the code. That said, I don't know that all other options have yet been ruled out; and, when folks encounter expensive models on large networks, there are various approximate solutions that they may be willing to live with. But if one is working with a dependence model on >=1e4 nodes, one must except that one may be in a regime in which gold-standard MCMC-MLE is very expensive. Just sayin'. Alternate parameters to tighten the MCMC: I have experimented with the MCMC sample size and interval parameters, but have not been able to improve the quality of the simulated network. I am not as familiar with what options are available within the bounds of some reasonable computational cost.

In summary, the problem remains that despite the ERGM convergence, the quality of the simulated networks suggests room for improvement, since the specified targets are not captured within the distribution of the simulated networks.

OK, let me see if I can offer some further advice, based on your email and also something that came up in your exchange with Pavel:

1. We should be clear that, assuming no-exotica, you should be assessing convergence from an MCMC run on the fitted model (as produced by gof() or done manually). So far, the plots I've seen appear not to be runs from the fitted model, so I have not actually seen evidence of the alleged phenomenon. Also, to be clear, (absent exotica) if your simulated mean stats don't match the observed stats (up to numerical and sometimes statistical noise), your model hasn't converged. A model that isn't converging is not the same as a model that has converged but that is inadequate, and the fixes are very different.

2. The exchange with Pavel led me to dig into your code a bit more, and I realized that you are not fitting to an observed network, but to target stats presumably based on design estimation. This could put you into the "exotica" box, because it is likely that - due to errors in your estimated targets - there exists no ERGM in your specified family whose expected statistics exactly match the target statistics. So long as they aren't too far off, you still ought to be able to get close, but hypothetically one could have a situation where someone gets an unusually bad estimate for one or a small number of targets, and their matches are persistently off; in this case, the issue is that the MLE no longer satisfies the first moment condition (expected statistics do not match the target statistics), so this is no longer a valid criterion for assessing convergence. If one is willing/able to make some distributional statements about one's target estimates, there are some natural relaxations of the usual convergence criteria, and almost surely Pavel has written them down, so I defer to him. :-) But anyway, if your model really seems not to be converging (by the criteria of (1)), and if you are using estimated target stats, then I would certainly want to investigate the possibility that your model has actually converged (and that you're just seeing measurement error in your target stats) before going much further. To write reckless words (that you should read recklessly), one naive heuristic that could perhaps be worth trying would be to look at the Z-scores (t_o- t_s)/(s2_o^2+s2_s^2)^0.5, where t_o is the observed (estimated) target, t_s is the simulated mean statistic, s2_o is the standard error of your target estimator, and s2_s is the standard error of the simulation mean. (If you are e.g. using Horvitz-Thompson, you can approximate s2_o using standard results, and you can likewise use autocorrelation-corrected approximations to s2_s.) If these are not large, then this suggests that the discrepancies between the targets and the mean stats are not very large compared to what you would expect from the variation in your simulation outcomes and in your measurement process. This does not take into account e.g. correlations among statistics, nor support constraints, but it seems like a plausible starting point. (Pavel and Martina have been working with these kinds of problems a lot of late, so doubtless can suggest better heuristics.)

3. Pavel's comments pointed to SAN, which also led me to observe that you are starting by fitting to an empty graph. I recommend against that. In principle, the annealer should get you to a not-too-bad starting point, but in my own informal simulation tests I have observed that this doesn't always work well if the network is very large; in particular, if SAN dumps you out with a starting point that is far from equilibrium, you are wasting a lot of MCMC steps wandering towards the high- density region of the graph space, and this can sometimes lead to poor results (especially if you can't afford to run some (large k)*N^2 burn-in - and recall that the default MCMC algorithm tends to preserve density, so if the seed is poor in that regard, it can take a lot of iterations to fix). My suggestion is to use rgraph() to get a Bernoulli graph draw from a model whose mixing characteristics (and, above all, density) approximate the target, and start with that. An easy way to set the parameters is to fit a pilot ERGM using only independence terms, use these construct a tie probability matrix, and pass that to the tp argument of rgraph(). Your case makes for a very large matrix, but it's still within the range of the feasible. (rgraph() does not use adjacency matrices internally, and so long as you set the return value to be an edgelist is not constrained by the sizes of feasible adjacency matrices, but if you want to pass an explicit tie probability matrix then obviously that puts you in the adjacency matrix regime.) Anyway, it's better to use rgraph() for this than an simulate() call, because it will be both faster and an exact simulation (no MCMC). A poorer approach not to bother with mixing structure, and just to draw an initial state with the right density (which at least reduces the risk that SAN exits with a graph that is too sparse)....but you might as well put your starting point as close to the right neighborhood as you can. The goal here is to help the annealer get you to a high-potential graph, rather than expecting it to carry you there from a remote location. It is possible that this turns out not to be a problem in your particular case, but it seems worth ruling out. Hope that helps,

-Carter

## Aditya Khanna

*Fri, Oct 18, 2024 at 7:22 AM*

Hi Carter and Pavel,

Thank you so much for your helpful suggestions. Following your feedback (and Carter’s numbering scheme below), I report the following:

1. The GOF plot is [here](https://github.com/hepcep/net-ergm-v4plus/blob/main/fit-ergms/out/oct12-2024-int1e6-samp1e6-hotelling_gof_plot.pdf) and the numerical summary is [here](https://gist.github.com/khanna7/f263b14b7bbc09e704ecd99bda8f215d). Based on these, it seems that the model has not converged. When we simulate from our best fit, even though it is not from a

converged model, the simulated networks seem not far off from the mean target statistics.

2. We have looked into the underlying uncertainty in the target statistics themselves, and these uncertainty regions are quite large. My question is: what is the best approach to handle these uncertain ranges in the target statistics? Is there a way to specify not just the mean but a range of target values for each of the specified ERGM parameters? I can conceptualize other

ways, for instance, sampling values from the uncertainty ranges for each parameter, and

fitting ERGMs to those configurations, for instance. But I am not sure if there is a

recommended heuristic to pursue?

3. I also tried your suggestion to start with a non-empty graph (whereas case 1 above is the GOF output on a fit that was generated where I started from an empty graph). The GOF plot

is here. I also combined the idea of starting with a non-empty graph with Pavel’s suggestion to not specify any arguments in control.ergm and let the algorithm figure it out (or just

specify the san in the control.ergm). That didn’t work either (see [Rout](https://github.com/hepcep/net-ergm-v4plus/commit/e65d499d4a1bbf5f5cfe43e8355f062045f090ef) from the session).

Thank you in advance for any thoughts you are able to share,

Aditya

## Steven M. Goodreau

*Fri, Nov 1, 2024 at 2:56 AM*

Hey there - I haven't been tracking this closely as of late since it seems like Carter and Pavel are providing help. But LMK if you could use another pair of eyes and want me to go through carefully.

Best,

Steve

## Aditya Khanna

*Sun, Nov 3, 2024 at 5:26 PM*

Hi Steve,

Thanks so much for checking in! I didn't hear back from either Carter or Pavel in response to my last message in this thread. I would be grateful if you have a chance to read that and share any thoughts.

Aditya

## Steven M. Goodreau

*Fri, Nov 15, 2024 at 4:57 AM*

I've spent a good bit of time going through your history here, and should be emailing the group tomorrow. - S

## Steven M. Goodreau

*Mon, Nov 18, 2024 at 7:35 AM*

Hi all,

So I was working through this email chain re Aditya's issue when I heard from Sam, and then spent time exploring both, given that there is some conceptual overlap. You should have just seen the email re Sam's issues. Re Aditya's: here are my various thoughts. I don't actually have advice on how to improve your model further, Aditya, sorry -- I'll have to leave that to Carter and Pavel. This is about the issues related to the process getting to this point. The email chain is long, so if I missed anything that answers one of these questions, forgive me:

- Aditya: it seems you've spent a long time trying to fit this model on ergm 4.x If I understand correctly, you were able to fit it in ergm 3.x. In the interest of moving your research forward, is there any reason you can't use the fit from 3.x for your simulations? I understand that ideally you would want it to fit just as easily in the latest version, but are you actually stuck in your research?

- Carter: you had mentioned somewhere about how complex models on large networks sometimes just take a really long time to fit, and there's no way around it. Totally agree. I think the issue, IIUC, is that in ergm 3.x, it didn't take nearly that long to converge. So that certainly suggests that it's possible to do it. Aditya, do I have that right? All: I understand that ergm 4.x's defaults are trying to tackle a wide range of models adaptively. And that might mean that any given model might not be as smooth as it was in ergm 3.x, while ergm 4.x still represents a step forward overall. That said, it seems as if Philip Leifeld had issues with a model fitting with 3.x defaults and not 4.x, and the advice that Chad gave then is similar to what Carter did now. And it's similar to what also seemed to help somewhat with Sam's model. So there does seem to be a large space of useful models that worked more smoothly in 3 than 4. So now I'm wondering: is there a way to set the parameters in ergm 4.x to create a fitting algorithm that perfectly matches what were the defaults in 3.x? If so, does a list of the parameters and their values needed to do this exist somewhere? Is it worth adding in a way to easily make that happen with a single argument (e.g. ergm3.defaults = TRUE)? Ideally one could set that and then still tweak on top of that, so that one could re-create a given model from ergm 3 that was mostly defaults but a few not. Thanks,

Steve

## Steven M. Goodreau

*Thu, Nov 21, 2024 at 10:17 PM*

Hi all -

You were so good in jumping on the issues Sam was facing so quickly - thank you for that! But I want to make sure the email chain about Aditya's issues doesn't get lost in the process....

Steve

## Aditya Khanna

*Thu, Nov 21, 2024 at 10:24 PM*

Thank you so much, Steve, for sending this reminder to the group! I had tried the ergm 3.x solution previously, but that didn’t work at all. It might be because that version of ergm is no longer compatible with the latest versions of R that are out there. The OS on my HPC system at Brown was also updated, making it impossible to work with older versions of R. At this point, the ergm 4 solution is close, with the main question being on how to best incorporate uncertainty in target parameters (see #2 below, email dated 10/17/2024). Points #1 and #3 provide updates on items suggested by Carter and Pavel.

Many thanks all,

Aditya

PS This message may not be delivered to statnet_dev, since I am not on that list.

## Steven M. Goodreau

*Fri, Nov 22, 2024 at 10:51 PM*

OK good to hear that things seem to generally be working.

Pavel et al - the broader question of whether want to change defaults, etc remains. Users of 4.x seem to keep hitting similar problems, and the solution seems to often be the same.

As for the range of uncertainty. Others on here have done more on this than I have, but I can share a few thoughts. First, the ergm.ego package implements methods to capture more of the uncertainty in input parameters derived from egocentrically sampled data. I haven't used it much myself so I'm not the best to ask. In particular, I don't have a sense of whether or how that uncertainty propagates into the ergm simulation models that then result - I think it does not at this point, but Pavel or Martina will know.

Beyond that, mostly I think that sampling from target stats distributions is the main way to go. This is very tricky, of course, since target stats are generally correlated with each other in complex ways. The details of how you do this will depend both on the goals of your estimation and simulation work and the set of statistics you have in there. If you want to write back with an example of a few terms and the main questions that the work is seeking to answer, we could brainstorm. Happy to do this one-on-one of you want.

Best,

Steve
