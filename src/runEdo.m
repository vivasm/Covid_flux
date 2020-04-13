function [PsA,PiA,PrA]=runEdo(bet,gam,Pop,PsA,PiA,PrA)

ids=find(Pop.Pi>=1);                   % Roda EDO apenas para muniipios infectados
S=Pop.Ps(ids);
I=Pop.Pi(ids);
beta=bet(ids);  
gamma=gam(ids);
                        % EQUAÇÃO EDO
dS= -beta.*S.*I;
dI= beta.* S.* I - gamma .* I;
dR= gamma .* I;

PsA(ids)=PsA(ids)+dS;
PiA(ids)=PiA(ids)+dI;
PrA(ids)=PrA(ids)+dR;
end