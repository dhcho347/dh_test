function dh_info(tf0)
    % s vari for TF
    s=tf('s');
    % x for symbolic
    syms x;

    tf_GD=tf0
    tf_CL=feedback(tf_GD,1)

    % check character

    % 1) 보드폼 (확인용)
    % bode from
    tfzpk=zpk(tf_GD);
    tfzpk.DisplayFormat='frequency';
    tfzpk
    
    % 2) Poles and zeros
    % 약분 전...
    p0x=pole(tf_GD); z0x=zero(tf_GD);
    p0CL=pole(tf_CL); z0CL=zero(tf_CL);
    p0x, z0x, p0CL, z0CL
    
    % 3) damp, wn
    damp(tf_GD)
    damp(tf_CL)

    % 4) tf to sym
    [Num,Den] = tfdata(tf_GD); % control TF
    num_p = poly2sym(cell2mat(Num),x);
    den_p = poly2sym(cell2mat(Den),x);
    tf_sym=num_p/den_p; % 약분 후 TF

    % 5) final value (dcgain)
    Kps=dcgain(tf_GD);    Kvs=dcgain(tf_GD*s);     Kas=dcgain(tf_GD*s^2); 
    Kp_Kv_Ka=[Kps,Kvs,Kas];Kp_Kv_Ka 
    Error=[1/(1+Kps),1/Kvs, 1/Kas,]; Error % error
    y_final=1-[1/(1+Kps),1/Kvs, 1/Kas, ];y_final % final value

    %6) step_infor
    step_info=stepinfo(tf_CL); step_info

end
