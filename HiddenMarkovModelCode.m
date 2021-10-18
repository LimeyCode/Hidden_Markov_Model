%clear all previous variables
clear();
figure
hold on;

%STEP 1
%==============================================================================================

%plot pdfs using table of variance and means for each state
fplot(@(x) (1/(2*pi*1.44)^(1/2))*exp((-(x-1)^2)/(2*1.44)), [-2 9])
fplot(@(x) (1/(2*pi*0.49)^(1/2))*exp((-(x-4)^2)/(2*0.49)),[-2 9])

%observation sequence
obs = [3.8,4.2,3.4,-0.4,1.9,3.0,1.6,1.9,5.0];

%STEP 2
%==============================================================================================
%calculate the probability densities of the observations using the ycords
y1Cord = [];
y2Cord = [];
for j = 1:length(obs)
    y1 = (1/(2*pi*1.44)^(1/2))*exp((-(obs(j)-1)^2)/(2*1.44));
    y2 = (1/(2*pi*0.49)^(1/2))*exp((-(obs(j)-4)^2)/(2*0.49));
    y1Cord = [y1Cord, y1];
    y2Cord = [y2Cord, y2];
end
plot(obs,y1Cord,'o')
plot(obs,y2Cord,'o')

%STEP 3
%==============================================================================================
%forward likelihood

%Initial calculation
alphaOne = 0.44 * y1Cord(1);
alphaTwo = 0.56 * y2Cord(2); 

arrayAlphaOne = [];
arrayAlphaTwo = [];
arrayAlphaOne = [arrayAlphaOne, alphaOne];
arrayAlphaTwo = [arrayAlphaTwo, alphaTwo];
%recursion
for i = 1:length(y1Cord)
    Temp = alphaOne;
    alphaOne = ((alphaOne*0.92 + alphaTwo*0.04))*y1Cord(i);
    alphaTwo = ((Temp*0.06 + alphaTwo*0.93))*y2Cord(i);
    arrayAlphaOne = [arrayAlphaOne, alphaOne];
    arrayAlphaTwo = [arrayAlphaTwo, alphaTwo];
end

%STEP 4
%==============================================================================================
%calculate p(O|Lambda)
alphaPOvalue = (alphaOne*0.02) + (alphaTwo*0.03);

%STEP 5
%==============================================================================================
%backward likelihood
betaOne = 0.02;
betaTwo = 0.03;

arrayBetaOne = []; 
arrayBetaTwo = [];
arrayBetaOne = [arrayBetaOne, betaOne];
arrayBetaTwo = [arrayBetaTwo, betaTwo];
%flip array to go from T to T-1,T-2...
flipY1Cord = [];
flipY2Cord = [];
flipY1Cord = flip(y1Cord);
flipY2Cord = flip(y2Cord);

for i = 1:length(y1Cord)
    Temp = betaOne;
    betaOne = (0.92*flipY1Cord(i)*betaOne)+(0.06*flipY2Cord(i)*betaTwo);
    betaTwo = (0.04*flipY1Cord(i)*Temp)+(0.93*flipY2Cord(i)*betaTwo);
    arrayBetaOne = [arrayBetaOne, betaOne];
    arrayBetaTwo = [arrayBetaTwo, betaTwo];
end
%Confirm p(O|Lambda)
betaPOvalue = (0.44*y1Cord(1)*betaOne)+(0.56*y2Cord(1)*betaTwo);

%STEP 6
%==============================================================================================
%Occupation Likelihoods

%Flip arrays for backward likelihood so T = 1, 2 ,3...
flipArrayBetaOne = [];
flipArrayBetaTwo = [];

flipArrayBetaOne = flip(arrayBetaOne);
flipArrayBetaTwo = flip(arrayBetaTwo);

OcupationLikelihoodsOne = [];
OcupationLikelihoodsTwo = [];

for i = 1:9
    ytStateOne = (arrayAlphaOne(i)*flipArrayBetaOne(i))/betaPOvalue;
    ytStateTwo = (arrayAlphaTwo(i)*flipArrayBetaTwo(i))/betaPOvalue;
    OcupationLikelihoodsOne = [OcupationLikelihoodsOne, ytStateOne];
    OcupationLikelihoodsTwo = [OcupationLikelihoodsTwo, ytStateTwo];
end 

%STEP 7
%==============================================================================================
 sumYtOtOne = 0;
 sumYtOtTwo = 0;
 %Loop to find Occupation at each T time frame
for i = 1:9
    sumYtOtOne = sumYtOtOne + (OcupationLikelihoodsOne(i)*y1Cord(i));
    sumYtOtTwo = sumYtOtTwo + (OcupationLikelihoodsTwo(i)*y2Cord(i));
end
sumOccupationOne = sum(OcupationLikelihoodsOne);
sumOccupationTwo = sum(OcupationLikelihoodsTwo); 
%re-calculation of state 1 and 2 means
meanOne = sumYtOtOne/sumOccupationOne;
meanTwo = sumYtOtTwo/sumOccupationTwo;

sumVarianceNumerOne = 0;
sumVarianceNumerTwo = 0;
%Calculate covaraince
for i = 1:9
    sumVarianceNumerOne = sumVarianceNumerOne + (OcupationLikelihoodsOne(i)*(y1Cord(i) - meanOne)^2);
    sumVarianceNumerTwo = sumVarianceNumerTwo + (OcupationLikelihoodsTwo(i)*(y2Cord(i) - meanTwo)^2);
end
%calculate variance for state 1 and 2
varianceOne = sumVarianceNumerOne/sumOccupationOne;
varianceTwo = sumVarianceNumerTwo/sumOccupationTwo;
%STEP 8
%===============================================================================================
%replot the reestimated pdfs
fplot(@(x) (1/(2*pi*varianceOne)^(1/2))*exp((-(x-meanOne)^2)/(2*varianceOne)), [-3 9])
fplot(@(x) (1/(2*pi*varianceTwo)^(1/2))*exp((-(x-meanTwo)^2)/(2*varianceTwo)),[-3 9])

hold off;

