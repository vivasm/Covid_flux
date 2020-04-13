function [PsA,PiA,PrA,PtA]=runFlux(mFlux,PopS,PopI,PopR,PopT,PsA,PiA,PrA,PtA)
assert(all(size(mFlux) <= [6000 6000]));
assert(isa(mFlux, 'double'));
assert(all(size(PopS) <= 6000));
assert(isa(PopS, 'double'));
assert(all(size(PopI) <= 6000));
assert(isa(PopI, 'double'));
assert(all(size(PopR) <= 6000));
assert(isa(PopR, 'double'));
assert(all(size(PopT) <= 6000));
assert(isa(PopT, 'double'));
assert(all(size(PsA) <= 6000));
assert(isa(PsA, 'double'));
assert(all(size(PiA) <= 6000));
assert(isa(PiA, 'double'));
assert(all(size(PrA) <= 6000));
assert(isa(PrA, 'double'));
assert(all(size(PtA) <= 6000));
assert(isa(PtA, 'double'));

N=length(PopS);
for i=1:N
    [PsA,PiA,PrA,PtA]=transp(i,mFlux,PopS,PopI,PopR,PopT,PsA,PiA,PrA,PtA);
    
end
end

%%
function [PsA,PiA,PrA,PtA]=transp(i,mFlux,PopS,PopI,PopR,PopT,PsA,PiA,PrA,PtA)

T=mFlux(i,:)';

% Estimate the fraction of each state to travel
Psx=(T*(PopS(i)/PopT(i))); 
Pix=(T*(PopI(i)/PopT(i)));
Prx=(T*(PopR(i)/PopT(i)));


% Decrease the population of Source
PsA(i)=PsA(i)-sum(Psx);
PiA(i)=PiA(i)-sum(Pix);
PrA(i)=PrA(i)-sum(Prx);
PtA(i)=PtA(i)-sum(T);
%Increase population of Target
PsA=PsA+Psx;
PiA=PiA+Pix;
PrA=PrA+Prx;
PtA=PtA+T;
PsA(PsA<0)=0;                 % Zera suscetíveis em caso de flutuação negativa
PiA(PiA<0)=0;                 % Idem Infectados
PrA(PrA<0)=0;                 % Idem Infectados
end
