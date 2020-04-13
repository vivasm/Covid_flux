function [beta,gamma]=montaBeta(betaTb,codTb,Pop)
    tam=length(Pop.id);
    beta=zeros(tam,1);
    gamma=zeros(tam,1);
    
    for i=1:tam
        cd=floor(Pop.id(i)/100000);         % pega os dois primeiros d�gitos do codigo
        sg=codTb.Sigla(find(codTb.Cod==cd));
        id=find(strcmp(betaTb.state,sg));
        beta(i)=betaTb.beta(id)/Pop.Pt(i);   % Divide Beta pela popula��o uma vez que os valores de S,I e R n�o s�o fra��es
        gamma(i)=betaTb.gamma(id);
    end    
end