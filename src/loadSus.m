function [Ps,Pr]=loadSus(Pop,susTb,data)
    Ps=Pop.Ps;
    Pr=Pop.Pr;
    t1 = datetime(data,'Format','dd/MM/uuuu');
    ids=find(datenum(susTb.date)==datenum(t1));
    tb=susTb(ids,:);
    for i=1:length(tb.ibgeID)
        id=find(Pop.id==tb.ibgeID(i));
        if ~isempty(id)             % apenas para casos loalizados na tabela
            Pr(id)=floor(tb.Recuperado(i));
            Ps(id)=Pop.Pt(id)-(Pop.Pi(id)+Pop.Pr(id));
        end
    end

end