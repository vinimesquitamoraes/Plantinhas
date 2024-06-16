pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--ed rocha te amo =================================================================================================================================================================+
function _init()
 --carrega save 
	cartdata("edevini_plantinhas_1")
 --inicia o mouse -----------------------------------------------------------------------------------------------------------------------------------------------------------------+
 poke(0x5f2d, 1)
  
	if false then
		for i=0,63 do dset(i,0) end
	end

 --cus ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
 espacamento = 0
 cu1 = 0
 cu2 = 0
 cu3 = 0
 --status -------------------------------------------------------------------------------------------------------------------------------------------------------------------------+	
 --[[
 status
 1 para a tela principal
 2 para loja
 3 para o deposito
 ]]
 status = 1

 --auxiliares ---------------------------------------------------------------------------------------------------------------------------------------------------------------------+
 aux_tipo    = 1
 grav        = 0
	max_saturac = 20
	venda       = false
	venda_timer = 0
	pisca       = false
 --variaveis de jogo --------------------------------------------------------------------------------------------------------------------------------------------------------------+
	saldo   = 0
	num_atl = 6
	slots   = 0
	
 --listas -------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
 ls_tst = {["tipo"]="teste"       ,["val"]=false,["qual"]=nil}
 ls_bts = {["tipo"]="botao"       ,["val"]=false,["qual"]=nil}
 ls_esp = {["tipo"]="espaco"      ,["val"]=false,["qual"]=nil,["esps"  ]={}                              ,["timer"]=0,["wait"]=false} 
 ls_plv = {["tipo"]="palavra"     ,["val"]=false,["qual"]=nil}
 ls_atl = {["tipo"]="atalho"      ,["val"]=false,["qual"]=nil,["atls"  ]={},["show" ]=false,["timer"]=0,["wait"]=false} 
 ls_car = {["tipo"]="carrinho"    ,["val"]=false,["qual"]=nil,["coisas"]={},["total"]=0    ,["timer"]=0,["wait"]=false} 
 ls_inv = {["tipo"]="inventario"  ,["val"]=true ,["qual"]=nil,["coisas"]={},                ["timer"]=0,["wait"]=false} 
 ls_jrd = {["tipo"]="jardim"      ,["val"]=true ,["qual"]=nil,["coisas"]={},                ["timer"]=0,["wait"]=false} 
 ls_prt = {["tipo"]="prateleiras" ,["val"]=false,["qual"]=nil}

 --listas de particulas -----------------------------------------------------------------------------------------------------------------------------------------------------------+
 pat_sem = {["tipo"]="semente",["val"]=false,["qual"]={} }	
 pat_reg = {["tipo"]="agua"   ,["val"]=false,["qual"]={} }	

 --init de palavras ---------------------------------------------------------------------------------------------------------------------------------------------------------------+
 p1={192,193,193,194,240}
 p2={208,193,192,240}
 p3={208,194,195,209,192,240} 
 p4={210,194,193,241,211,224,240}
 p5={208,224,227,243,211}
 p5={208,224,227,243,211}
 p6={225,226,242}
 p7={244,245,246}
 
 tools   = criar_obj("palavra",0,ls_plv,p1,11,  4)
 pots    = criar_obj("palavra",0,ls_plv,p2,11, 32)
 plants  = criar_obj("palavra",0,ls_plv,p3,11, 60)
 flowers = criar_obj("palavra",0,ls_plv,p4,11, 88)
 price   = criar_obj("palavra",0,ls_plv,p5,17,120)
 buy     = criar_obj("palavra",0,ls_plv,p6,99,118)
 buy_atv = criar_obj("palavra",0,ls_plv,p7,99,118)
 
 --instancias ---------------------------------------------------------------------------------------------------------------------------------------------------------------------+
 
 --cursor .........................................................................................................................................................................+
 mouse = criar_obj("mouse",0)

 --botoes .........................................................................................................................................................................+
 bt_loja = criar_obj("botao",1,ls_bts)
 bt_volt = criar_obj("botao",2,ls_bts)
 bt_comp = criar_obj("botao",3,ls_bts)
 bt_dept = criar_obj("botao",4,ls_bts)
 bt_vend = criar_obj("botao",5,ls_bts)

 --espacos da lojinha .............................................................................................................................................................+
 init_loja()
 
 --prateleiras ....................................................................................................................................................................+
 init_prat(4)

 --objetos funcionais padrao ------------------------------------------------------------------------------------------------------------------------------------------------------+
 regador = {["nome"]="invalid"}
 pa      = {["nome"]="invalid"}

	--atalhos
 init_atl(num_atl)
 def_pos_atls()
	--caregar save
 load_game()

end

--update ==========================================================================================================================================================================+
function _update()
 mouse:att()
	if(btnp(❎)) saldo = 6000

 --cooldown para os bts
 foreach(ls_bts,function(obj) cool_down(5,obj) end)

 --atualizar particulas
 att_particulas(pat_sem)
 att_particulas(pat_reg)

 --jogo principal rocha --------------------------------------------------------------------------------------------+	
 if status == 1 then
       
 --ir depot .......................................................................................................
 if ls_atl.show then
  bt_dept:hover()
  bt_dept:ativa()
 end
  
 --ir loja ........................................................................................................   
 if not ls_atl.show and not ls_atl.val and not ls_jrd.qual then
  bt_loja:hover()
  bt_loja:ativa()
 end
  
 --performar atribuicao
 if(ls_atl.show and ls_atl.qual)toggle_atribuir()
 --se o timer contou ja
 if(ls_atl.wait)funcionalidades(2,ls_jrd)
	
 --colisao atalhos ------------------------------------------------------------------------------------------------------+
 cool_down(5,ls_atl)
 if ls_atl.show then
  check_sel_and_mov(ls_atl.atls,ls_atl,"circ")	 
 end
  
 --colisao jardim -------------------------------------------------------------------------------------------------------+
 --delay pra comecar a mover
 cool_down(15,ls_jrd)
 
 if not ls_atl.show and ls_jrd.wait then
  check_sel_and_mov(ls_jrd.coisas,ls_jrd,"retg",ls_jrd.val)	 
 end

 --regar -------------------------------------------------------------------------------------------------------+
 if pat_reg.val and not ls_atl.show then
  if(mouse:toggle(mouse.esq,204,236)) gerar_part(pat_reg, 1, nil, 2, 3, nil, stat(32)+1, stat(33)+13) 
 end
  
 --semear -------------------------------------------------------------------------------------------------------+
 if pat_sem.val and not ls_atl.show and #pat_sem<1 then
  if(mouse:toggle(mouse.esq,228,228))then
   gerar_part(pat_sem,1,ls_atl.qual.item,1,5,ls_atl.qual.item, stat(32)+2, stat(33)+7)
   if ls_atl.qual.item.capacity == 0 then
    ls_atl.qual.item = nil
    ls_atl.qual = nil
   end
  end
 end
 
 --remover planta ------------------------------------------------------------------------------------------+
 if pa.val and not ls_atl.show then
  if(mouse:toggle(mouse.esq,238,206)) remov_planta()
	end
	
 --esperando awa -------------------------------------------------------------------------------------------------------+ 	
 foreach(pat_reg,function(obj) regar(obj) end)
  
 --esperando semente -------------------------------------------------------------------------------------------------------+
 foreach(pat_sem,function(obj) plantar(obj) end)
 
 --cancelar atribuicao/mostrar atalho
 atl_on_off(mouse.dir_press,true)	

 --lojinha rocha ---------------------------------------------------------------------------------------------------+				
 elseif status == 2 then
		--verificar disponibilidade de compra
		if(slots == 63)toggle_disp(1,16) else toggle_disp(1,16,true)
		
  --selecionar loja ................................................................................................+
 	foreach(ls_esp.esps,function(esp) esp:hover("retg" ) end)
	 check_sel_and_mov(ls_esp.esps,ls_esp,"retg")										
      
  --selecionar compra ..............................................................................................+
  if ls_esp.qual then
   mouse:tip_set(231,"➡️","")
 		ls_esp.qual:add_car()	
  end  
  
  --colisao no carrinho ............................................................................................+
  if(not ls_car.val and #ls_car.coisas >0) then
   foreach(ls_car.coisas,function(esp) esp:hover("retg") end)
   check_sel_and_mov(ls_car.coisas,ls_car,"retg")
  end
   
  --remover carrinho ...............................................................................................+
  if ls_car.qual then
   mouse:tip_set(232,"➡️","")
  	ls_car.qual:del_car()	
  end
  			
  bt_comp:hover()
  bt_comp:ativa()			
  bt_volt:hover()
  bt_volt:ativa()
	
  if(not ls_esp.qual and not ls_car.qual)mouse:reset()
		att_car()

 --deposito rocha --------------------------------------------------------------------------------------------------+
 elseif status == 3 then
  grav_depot()

  --checar colisao =================================================================================================+
		--atalhos --------------------------------------------------------------------------------------------------------+
  cool_down(5,ls_atl)
  if(ls_atl.show) then
   check_sel_and_mov(ls_atl.atls,ls_atl,"circ")	 
  end
  
		--inventario -----------------------------------------------------------------------------------------------------+
	 --delay pra comecar a mover
	 cool_down(5,ls_inv)
		if(not ls_atl.show and ls_inv.wait) then
   check_sel_and_mov(ls_inv.coisas,ls_inv,"retg",ls_inv.val)	 
  end

  --performar atribuicao
  if(ls_atl.show and ls_atl.qual)toggle_atribuir()
  --se o timer contou ja
  if(ls_atl.wait)funcionalidades(1,ls_inv)
  
  if(not venda)atl_on_off(mouse.dir_press)	
     
  if ls_atl.show then
   bt_dept:hover()
   bt_dept:ativa()
  end
  
  if not ls_atl.show and not ls_atl.val and not ls_inv.qual then
   bt_vend:hover()
   bt_vend:ativa()
  end
		
		if(venda and ls_inv.qual and not(mouse.eq_press) and mouse.esq_press)then
			local vendido = ls_inv.qual
		 if vendido != regador and vendido != pa then
				saldo += vendido.val
				del(ls_inv.coisas,ls_inv.qual)
			end
		end
		 	
 end

	save_game()

end

--draw =============================================================================================================+
function _draw()
 cls()

 --jogo principal --------------------------------------------------------------------------------------------------+
 if status == 1 then
 	
  bt_loja:des() 
  des_jardim()
  
  --particulas -----------------------------------------------------------------------------------------------------+
  des_particulas(pat_sem)
 	des_particulas(pat_reg)
 	
 	--atalhos --------------------------------------------------------------------------------------------------------+	
  des_atl()

 --loljinha --------------------------------------------------------------------------------------------------------+
 elseif status == 2 then
  des_lojinha()
 
 --deposito -------------------------------------------------------------------------------------------------------+
 elseif status == 3 then
  des_depot()
  des_atl()
 end
 
 debug_obj(ls_inv.qual, 8)
 debug_obj(ls_jrd.qual, 9)
 if(ls_atl.qual)debug_obj(ls_atl.qual.item,10)
  
 mouse:des()

 print(cu1,0,0)
 
	print("slots:"..slots.."/63",85,0,6)
end

-->8
--classes ==========================================================================================================+
function criar_obj(que_classe,subtipo,ls_guardar,ls_aux,xop,yop,onde)
 local novo_obj = {
  --atributos ------------------------------------------------------------------------------------------------------+
	 onde     = onde or 0,
  x				    = xop  or 0,
  y 			    = yop  or 0,
  cla      = que_classe,
  tip      = 0,
  algo     = 0,
  capacity = 0,
  qual_atl = 0,
  s        = 0,
  cur_s    = 0,
  w        = 8,
  h        = 8,
  r        = 1,
  n        = 0,
  xoff     = 0,
  yoff     = 0,
  hoff     = 0,
  woff     = 0,
 	y_vel    = 1,
 	flip_x   = false,
 	flip_y   = false,
  movable  = false,
  ct       = 0,
  id       = 0,
  ls_gua   = ls_guardar,
  ls_aux   = ls_aux or nil,
  --metodos--------------------------------------------------------------------------------------------------------+ 			
  --mover objeto ..................................................................................................+
  mov = function(self, newx, newy)
   self.x = newx& ~1
   self.y = newy& ~1
  end,
  	 
	 --desenhar objeto
	 des = function(self,xop,yop)
	 	aux_x = xop or self.x  
	 	aux_y = yop or self.y
	  pal(self.ct,0)
	 	spr(self.s,aux_x,aux_y,self.w/8,self.h/8,self.flip_x,self.flip_y)
			pal()
	 end,
	 
	 --mover com o cursor
	 mov_cur = function(self,contexto,pode_mover)
			if(contexto and self.movable and pode_mover)self:mov((stat(32) - flr(self.w/2)),(stat(33) - flr(self.w/2)))
			n_sai_tela(self)
			return que_botao
	 end,

	 --checa colisao entre algo e 
		--o cursor
  col_mouse =	function(self,tipo)
			if tipo == "retg" then
				--checar entre direita e esquerda, cim e baixo
				esq =  self.x+self.xoff
				dir = (self.x+self.xoff)+(self.w-self.woff)
				cim =  self.y+self.yoff
				bax = (self.y+self.yoff)+(self.h-self.hoff)
					
				return (stat(32)>=esq and (stat(32)) <= dir) and
       				(stat(33)>=cim and (stat(33)) <= bax)
	 	
			elseif tipo == "circ" then
				dx   = self.x - stat(32)
				dy   = self.y - stat(33)
				dist = flr(sqrt((dx*dx)+(dy*dy)))
				return dist <= self.r				
				
	 	end
	 
 end	
	}
	
 def_tip(novo_obj,subtipo,ls_guardar) 

 add(ls_guardar,novo_obj)

 return novo_obj
end
-->8
--def_tipos ====================
function def_tip(self,subtipo)

 --mouse ========================		 
	if self.cla == "mouse" then
 self.s,self.ct,self.woff,self.hoff,self.ax,self.ay,self.esq_esper,self.mei_esper,self.dir_esper,self.esq_press,self.mei_press,self.dir_press,self.esq,self.mei,self.dir,self.esq_solto,self.mei_solto,self.dir_solto = 212,1,8,8,0,0,false,false,false,false,false,false,false,false,false,false,false,false
 			
	--resetar mouse ===============
 function self:reset()
  self.s,self.tool_tip,self.h,self.w,self.ct,self.xoff,self.yoff,self.ax,self.ay = 212, nil, 8,8,1,0,0,0,0
	end
	
	--mudar tool_tip
	function self:tip_set(qual,dir_x,dir_y)
	 self.tool_tip,dir_x,dir_y  = qual or nil,dir_x,dir_y
  
		if dir_x == "⬅️" then
		 self.xoff = -8		
		elseif dir_x == "➡️" then
			self.xoff =  8
		else
			self.xoff =  0
		end

		if dir_y == "⬆️" then
		 self.yoff = -9		
		elseif dir_y == "⬇️" then
			self.yoff =  9
		else
			self.yoff =  0
		end

	end
 	 
	--desenhar mouse ==============
 function self:des()
  local aux_x, aux_y = self.ax,self.ay
  pal(self.ct,0)
  spr(self.s,stat(32)+aux_x,stat(33)+aux_y,self.w/8,self.h/8)
 	if(self.tool_tip)spr(self.tool_tip,stat(32)+mouse.xoff,stat(33)+mouse.yoff)
		pal()
 end
 
 function self:toggle(que_bt,spr_1,spr_2)
 	if que_bt then
 	 mouse.s = spr_2
 	 return true
 	end

  mouse.s = spr_1
	 return false
 end
 
 --atualizar mouse =============
 function self:att()
 	--att posicao ================
  self.x,self.y,self.esq,self.mei,self.dir = stat(32),stat(33),stat(34)==1,stat(34)==4,stat(34)==2
	
		--comportamento esquerdo ||||
		--se o mouse esq foi apertado
		if self.esq then
			--se ele estava solto
			if self.esq_solto then
				--agora nao esta mais
				self.esq_solto=false
			end

			--se ele nao estava pressio
			--nado
			if not self.esq_press then
		 	--se nao estava esperando
				if(not self.esq_esper) then
		 		--agora esta pressionado
		 		--e esperando
					self.esq_press,	self.esq_esper = true,true
				end
			--se ja estava pressionado
			else
				--agora no esta mais
				self.esq_press = false
			end
			
		--se o mouse esq nao foi
		--apertado
		else
		--se estava pressionado
			if (self.esq_press) then
				--agora nao esta mais
				self.esq_press=false
			end
			
			--se nao esatava solto
			if not self.esq_solto then
				--se estava esperando
				if self.esq_esper then
					--agora esta solto e nao esta mais esperando
					self.esq_solto,self.esq_esper = true,false
		
    end
   --se estava solto
   else
   	--agora nao esta mais
   	self.esq_solto = false
   end
	 end
			 
 	--comportamento direita ||||||
		--se o mouse dir foi apertado
		if self.dir then
			--se ele estava solto
			if self.dir then
				--agora nao esta mais
				self.dir_solto=false
			end
			
			--se ele nao estava pressio
			--nado
			if not self.dir_press then
		 	--se nao estava esperando
				if(not self.dir_esper) then
		 		--agora esta pressionado
		 		--e esperando
					self.dir_press = true
					self.dir_esper = true
				end
			--se ja estava pressionado
			else
				--agora no esta mais
				self.dir_press = false
			end
			
		--se o mouse dir nao foi
		--apertado
		else
		--se estava pressionado
			if (self.dir_press) then
				--agora nao esta mais
				self.dir_press=false
			end
			
			--se nao esatava solto
			if not self.dir_solto then
				--se estava esperando
				if self.dir_esper then
					--agora esta solto
					self.dir_solto = true
					--e nao esta mais esperando
     self.dir_esper = false
    end
   --se estava solto
   else
   	--agora nao esta mais
   	self.dir_solto = false
   end
	 end
	end

--particula ====================
	elseif self.cla == "particula" then	
		self.vx,self.vy,self.x_max,self.x_mix,self.w,self.h = rnd(2)-1,1,128,0,0,0

 	if subtipo == 1 then 		
 		self.cor,self.ace = rnd({3,11}),0
 	elseif subtipo == 2 then
 		self.cor,self.ace = 12, 0.2
 	end

		function self:att()			
			self.x  +=	self.vx
			self.y  += flr(self.vy)
  	self.vy += self.ace
  	
			if self.x>=self.x_max then
				self.x = self.x_max
				self.vx *= -1

			elseif self.x<=self.x_min then
				self.x  = self.x_min
				self.vx *= -1
			end
			
			if(saiu(self))then
				pat_sem.val = false
				self:del()
			end
		end
		
		function self:des()
	  pset(self.x,self.y,self.cor)
	 end
	 
	 function self:del()
			if self then
			 del(self.ls_gua, self)
	 	 self = nil
			end
	 end
	
--botao ========================		 
	elseif self.cla == "botao" then
 	self.timer,self.wait,self.val = 0 ,false, true
		 
		--lojinha
		if subtipo == 1 then
 		self.tip,self.x,self.y,self.w,self.h,self.tam,self.s,self.sr,self.sp,self.ct=1,1,113,16,16,2,14,14,46,1
		 
	 --voltar
		elseif subtipo == 2 then
	 	self.tip,self.x,self.y,self.w,self.h,self.tam,self.s,self.sr,self.sp,self.ct = 2,1,113,16,16,2,12,12,44,0

		--comprar
		elseif subtipo == 3 then
   self.tip,self.x,self.y,self.w,self.h,self.cor1,self.cor3,self.cor2=3,97,116,18,8,5,5,10

	 --depot
		elseif subtipo == 4 then
  	self.tip, self.x, self.y, self.w, self.h, self.tam, self.s, self.sr, self.sp, self.ct = 4, 57, 57, 16, 16, 2, 40, 40, 42, 1
	  
		elseif subtipo == 5 then
 	self.tip, self.x, self.y, self.w, self.h, self.tam, self.s, self.sr, self.sp, self.ct = 5, 112, 113, 16, 16, 2, 14, 14, 46, 1
	 end
	
	 --metodos de botoes
	 
	 --ativar botao
		function self:ativa()
			--teve colisao
			--mouse esquerdo pressionado			
			if(self:col_mouse("retg") and not(mouse.eq_press) and mouse.esq_press and self.wait)then
				--funcoes ===================
				--ir lojinha
				if self.tip == 1 then
					status = 2		
	   	mouse:reset()
	  			 
				--voltar jogo principal
				elseif self.tip == 2 then
					status = 1
					 	 
				--comprar
				elseif self.tip == 3 then		
					comprar()				
							 
				--ir depot
				elseif self.tip == 4 and not ls_atl.val then
					if status==1 then
						status, bt_dept.s, bt_dept.sr, bt_dept.sp, self.ct, ls_inv.wait = 3, 12, 12, 44, 0, false

					elseif status==3 then
		   	bt_dept.s, bt_dept.sr, bt_dept.sp, status, ls_atl.val, self.ct, ls_jrd.wait, ls_atl.qual = 40, 40, 42, 1, false, 1, false     					 
				 end				
				 
					ls_atl.show = false
					foreach(ls_bts,function(obj) obj.wait = false end)
	 		elseif self.tip == 5 then
	    	mouse:reset()
						venda = not venda
						ls_inv.val = not ls_inv.val
				end
			end
		end
		
		function self:hover()
			
			if(self:col_mouse("retg") and self.wait)then

				if(self.tip == 3 and count(ls_car.coisas)>0)then				
				 self.cor1 =	self.cor2
				else
				 self.cor1,self.s  =	self.cor3,self.sp
				end
	
			else
			
			 self.cor1,	self.s =	self.cor3,self.sr	
			
			end
		end
	
	elseif self.cla == "espaco" then
  self.w, self.h, self.tam, self.disp, self.item = 18, 18, 16, true, {}

 	if(range(subtipo,1,2))then
 		function self:des()
    rect(self.x,self.y,self.x+self.w-1,self.y+self.h-1,self.cor1)	
	   rectfill(self.x+1,self.y+1,(self.x+self.w-1)-1,(self.y+self.h-1)-1,0)	
    self.item:des(self.x+1,self.y+1)
    if not self.disp then
 	   line(self.x+3 ,self.y+2,self.x+14,self.y+13,8)
 	   line(self.x+3 ,self.y+3,self.x+14,self.y+14,8)
	   	line(self.x+3 ,self.y+4,self.x+14,self.y+15,8)
    end
    des_vertices(self.x+1,self.y+1,self.w-2,self.h-2,self.cor1)
			end
		end
 	--espaco da loja
 	if subtipo == 1 then
 	 self.cor1,self.cor3,self.cor2 = 1,1,7

	 	function self:disp_toggle(qual)
 			self.disp = qual or false
			end
					 
		 function self:add_car()
				if mouse.esq_press then
				--adiciona ao carrinho
					if #ls_car.coisas<4 then
				 	if self.disp then
					  new_car       = criar_obj("espaco",2,ls_car.coisas)
							new_car.item  = criar_obj("item",self.item.tip)
							ls_car.total += self.item.val
						end
			 	end
			 end
			end
			
		--carinho	
 	elseif subtipo == 2 then
			self.cor1,self.cor3,	self.cor2 = 1,1,8
	 	
	 function self:del_car()
	 	if mouse.esq_press then
				ls_car.total -= self.item.val
			 del(ls_car.coisas,self)
			 ls_car.qual = nil
			end
	 end
	 	
		--atalho
 	elseif subtipo == 3 then
 		self.x,self.y,self.w,self.h = 64,64,16,16
		end

		function self:hover(tip_col)

			if(self:col_mouse(tip_col))then
			 self.cor1 = self.cor2
			else
			 self.cor1,self.qual,self.val = self.cor3,nil,false
			end
			
		end
		
	elseif self.cla == "prateleira" then			
		self.h,	self.w = 1,80
		
	elseif self.cla == "item" then				
		self.w, self.h, self.movable, self.desc = 16, 16, true, 10

		--slot de atalho
		if subtipo == 1 then
   self.tip, self.val, self.nome, self.s, self.xoff, self.yoff, self.woff, self.hoff, self.cur_s, self.ct = 1, 2000, "inv slot", 2, 2, 2, 5, 5, 214, 1

		--fertilizante
	 elseif subtipo == 2 then
 	 self.tip, self.val, self.nome, self.s, self.xoff, self.yoff, self.woff, self.hoff, self.cur_s, self.ct, self.capacity = 2, 800, "fertilizer", 8, 3, 1, 7, 4, 216, 1, 1
			
		--borrifador
	 elseif subtipo == 3 then
 		self.tip, self.val, self.nome, self.s, self.xoff, self.yoff, self.woff, self.hoff, self.cur_s, self.capacity = 3, 400, "pesticide", 6, 3, 1, 7, 4, 229, 5
			
		--cesta	 	
	 elseif subtipo == 4 then
   self.tip, self.val, self.nome, self.s, self.xoff, self.yoff, self.woff, self.hoff, self.ct, self.cur_s, self.capacity = 4, 300, "basket", 4, 0, 6, 1, 8, 1, 215, 0
			
	 --vasos rocha
	 elseif(range(subtipo,5,8))then
   self.estagio, self.colher, self.saturac, self.cur_s = 1, false, 0, 230
			
  	function self:des_planta()
  		local aux = self.planta.wh[self.estagio][1]
		  pal(self.planta.ct,0)
  		if aux > 1 then
  		 spr(self.planta[self.estagio],self.x          ,self.yp-(self.planta.wh[self.estagio][2]*8),self.planta.wh[self.estagio][1],self.planta.wh[self.estagio][2])
  		else
  		 spr(self.planta[self.estagio],self.x+self.xesp,self.yp-(self.planta.wh[self.estagio][2]*8),self.planta.wh[self.estagio][1],self.planta.wh[self.estagio][2])
  		end
				pal()

  	end
  	
  	function self:vasar()
  		gerar_part(pat_reg, 1, nil, 2, 3, nil,self.x+4 ,self.y+self.h-2)
  		gerar_part(pat_reg, 1, nil, 2, 3, nil,self.x+11,self.y+self.h-2)				  		
  	end
  	
  	function self:des(xop,yop)
  		self.x = xop or self.x
		 	self.y = yop or self.y
		 	--cordenadas onde planat fica no vaso		 	
		 	self.xp = self.x+self.xpoff
		 	self.yp = self.y+self.ypoff

		  pal(self.ct,0)
		 	spr(self.s,self.x,self.y,self.w/8,self.h/8)
				pal()
				
				if(self.planta and self.algo == 1)self:des_planta()
  	end
			
			--vaso1
		 if subtipo == 5 then
	  	self.tip, self.val, self.nome, self.s, self.xoff, self.yoff, self.woff, self.hoff, self.ct, self.xpoff, self.xesp, self.ypoff = 5, 500, "flowerpot 1", 32, 2, 5, 5, 8, 1, 8, 4, 8
		
			--vaso2
		 elseif subtipo == 6 then
		  self.tip, self.val, self.nome, self.s, self.xoff, self.yoff, self.woff, self.hoff, self.ct, self.xpoff, self.xesp, self.ypoff = 6, 500, "flowerpot 2", 34, 2, 5, 5, 7, 1, 8, 4, 7
		 			 
			--vaso3
		 elseif subtipo == 7 then
		  self.tip, self.val, self.nome, self.s, self.xoff, self.yoff, self.woff, self.hoff, self.ct, self.xpoff, self.xesp, self.ypoff = 7, 600, "flowerpot 3", 36, 3, 2, 7, 5, 2, 8, 4, 5

			--vaso4
		 elseif subtipo == 8 then
		  self.tip, self.val, self.nome, self.s, self.xoff, self.yoff, self.woff, self.hoff, self.ct, self.xpoff, self.xesp, self.ypoff = 8, 600, "flowerpot 4", 38, 1, 2, 3, 5, 2, 8, 4, 5
 
	 	end	
		--planta1
	 elseif(range(subtipo,9,16))then
	  self.s, self.ct, self.xoff, self.yoff, self.woff, self.hoff, self.cur_s, self.capacity = 10, 1, 2, 2, 5, 5, 249, 1

		 if subtipo == 9 then
		  self.tip, self.val, self.nome = 9, 400, "tomato"
		 	self.fases= {70   ,71   ,87   ,85   ,72   ,104 ,
           wh = {{1,1},{1,1},{1,2},{2,2},{2,2},{2,2}},
          tip = self.tip}
		 		 
			--planta2
		 elseif subtipo == 10 then
		  self.tip, self.val, self.nome = 10, 500, "bear_pawn"	
		 	self.fases= {64   ,65   ,66   ,67   ,68   ,74   , 
           wh = {{1,1},{1,1},{1,1},{1,1},{2,1},{2,2}},
          tip = self.tip}					 
			  	
			--planta3
		 elseif subtipo == 11 then
	  	self.tip, self.val, self.nome = 11, 600, "pumpkin"
		 	self.fases= {96   ,97   ,114  ,115  ,117  ,168  ,136  ,
           wh = {{1,1},{1,1},{1,1},{2,1},{2,1},{2,2},{2,2}},
          tip = self.tip}			 
			  				 		 	
		 --planta4
		 elseif subtipo == 12 then
		  self.tip, self.val, self.nome = 12, 1000, "pegaxi"
 	 	self.fases= {96   ,97   ,114  ,115  ,117  ,106  ,108  ,
           wh = {{1,1},{1,1},{1,1},{2,1},{2,1},{2,2},{2,2}},
          tip = self.tip}				 
  				 		 			  	
		 --planta5
		 elseif subtipo == 13 then
    self.tip, self.val, self.nome = 13, 500, "sunflower"
			 self.fases= {96   ,80   ,81   ,82   ,83   ,84   ,
           wh = {{1,1},{1,1},{1,1},{1,2},{1,2},{1,2}},
          tip = self.tip} 					 
		
		 --planta6
		 elseif subtipo == 14 then
		  self.tip, self.val, self.nome = 14, 350, "sword"	 	
			 self.fases= {64   ,112  ,113   ,130 ,132  ,134  ,
           wh = {{1,1},{1,1},{1,1},{2,1},{2,2},{2,2}},
          tip = self.tip} 					 
				self.fases.ct = 2

		 --planta7
		 elseif subtipo == 15 then
		  self.tip, self.val, self.nome = 15, 600, "rose"
			 self.fases= {70   ,176  ,177  ,162  ,163  ,164  ,165  ,
           wh = {{1,1},{1,1},{1,1},{1,2},{1,2},{1,2},{1,2}},
          tip = self.tip} 					 
				self.fases.ct = 2
				
		 --planta8
		 elseif subtipo == 16 then
		  self.tip, self.val, self.nome = 16, 1000, "dandelion"
			 self.fases= {70   ,128  ,129  ,146  ,138  ,140  ,
           wh = {{1,1},{1,1},{1,1},{2,1},{2,2},{2,2}},
          tip = self.tip}					 
	 	end
	 	
  elseif(range(subtipo,17,18))then
	  self.val   = false
	
			--regador
		 if subtipo == 17 then
  	 self.tip, self.nome, self.s, self.s2, self.s3, self.xoff, self.yoff, self.woff, self.hoff, self.cur_s = 17, "watering can", 204, 236, 204, 3, 1, 7, 4, 248
 			
			--pa
		 elseif subtipo == 18 then
	  	self.tip, self.nome, self.s, self.s2, self.s3, self.xoff, self.yoff, self.woff, self.hoff, self.cur_s, self.ct, self.x_def, self.y_def = 18, "shovel", 206, 238, 206, 3, 1, 7, 4, 213, 9, 32, 12
		 end 		 
		end
	
	--palavra	
	elseif self.cla == "palavra" then				
  self.w, self.h, self.cor1, self.cor2 = count(self.ls_aux), 4, 5, 5

 	function self:des()
			local aux = 0
			for i in all(self.ls_aux)do
				spr(i,self.x+aux,self.y)
				aux +=5
			end
		end
			
	end
	
end

-->8
--colisor e utilitrios =========
--nao deixa um objeto sair
--da tela
function n_sai_tela(oque)
	if oque != nil then
		esq = oque.x+oque.xoff
		cim = oque.y+oque.yoff
		dir = esq+oque.w-oque.woff
		bax = cim+oque.h-oque.hoff
	
		if(esq <   0) oque.x = -oque.xoff
		if(cim <   0) oque.y = -oque.yoff
 	if(dir > 127) oque.x = oque.x+(127-dir)
 	if(bax > 127) oque.y = oque.y+(127-bax)-1
	end
end

--saiu da tela
function saiu(oque)
	if oque != nil then
		esq = oque.x+oque.xoff
		cim = oque.y+oque.yoff
		dir = esq+oque.w-oque.woff
		bax = cim+oque.h-oque.hoff
			
		if(esq < 0) return true
		if(cim < 0) return true
 	if(dir > 127) return true
 	if(bax > 127) return true
 	return false
	end
end

--checa colisao entre dois retangulos
function col_2ret(q1,q2)
 if(not q1 or not q1)return
	esq_1 = q1.x+q1.xoff
	cim_1 = q1.y+q1.yoff
	dir_1 = esq_1+q1.w-q1.woff
	bax_1 = cim_1+q1.h-q1.hoff
	
	esq_2 = q2.x+q2.xoff
	cim_2 = q2.y+q2.yoff
	dir_2 = esq_2+q2.w-q2.woff
	bax_2 = cim_2+q2.h-q2.hoff

	--checar entre direita e esquerda
	if esq_1 < dir_2 and dir_1 > esq_2 then
  if cim_1 < bax_2 and bax_1 > cim_2 then
			return true
		end
	end

	return false	
	
end

--colisao de dois circulos
function col_circ(q1,q2)
	dx   = q1.x - q2.x
	dy   = q1.y - q2.y
	dist = sqrt((dx*dx)+(dy*dy))
	if(dist <= (q1.r+q2.r))then
		return true
	end	
	
	return 
	
end

--colisa de um circulo e 1 ponto
function col_circ_pt(cic,pt)
	dx   = cic.x - pt.x
	dy   = cic.y - pt.y
	dist = flr(sqrt((dx*dx)+(dy*dy)))
	if(dist <= (cic.r))then
		return true
	end
	
	return false
	
end

--retorna o obejto selecionado
--em uma lista
function get_obj_by_col_mos(lista,tipo)
	
	for qual in all(lista)do
		
		if(qual:col_mouse(tipo))return qual
				
	end	

end

function get_obj_by_col_retg(ls_oque_1,oque_2)
	
	for qual in all(ls_oque_1)do
		if(col_2ret(qual,oque_2))return qual
	end	
	
	return 
	
end

--checa a selecao de objetos
--em uma lista
--se um deles ja estiver sido 
--nao  checado
function check_sel_and_mov(qual_ls,controle,tipo,pode_mover)
 pode_mover = pode_mover or false

 --se tem alguem selecionado
	if controle.qual then
		if(not controle.qual:mov_cur(mouse.esq,pode_mover) and not controle.qual:col_mouse(tipo)) controle.qual = nil
  if(controle.qual and stat(34)==3)then
   add(qual_ls,del(qual_ls,controle.qual))
  end
	--se nao tem ninguem selecionado
	else
		controle.qual = get_obj_by_col_mos(qual_ls,tipo) 
	end
	
end

--desenhar vertice
function des_vertices(x,y,w,h,cor)

 pset(x    ,y    ,cor)
 pset(x+w-1,y    ,cor)
 pset(x    ,y+h-1,cor)
 pset(x+w-1,y+h-1,cor)

end

--apaga uma lista
function del_ls(qual_ls)
	for i in all(qual_ls)do
		del(qual_ls,i)
	end
end

--particulas
function des_particulas(que_ls)
	foreach(que_ls,function(p) p:des() end)
end

--atualizar prticulas
function att_particulas(que_ls_part)
	
 for p in all(que_ls_part) do
 	p:att() 
 	if(#que_ls_part>0 and que_ls_part.tipo == "semente")ls_jrd.val = false
 end 
		 
end

function gerar_part(que_pat_ls, quantas, do_que, tip, ampx, item, x, y)
 tip = tip or 1
	
 if(do_que and quantas>do_que.capacity or #que_pat_ls+quantas > 200)return
 if(do_que) do_que.capacity -= 1
 
 for i=1, quantas do
		nova = criar_obj("particula",tip,que_pat_ls,item)
		nova.x, nova.y, nova.x_max, nova.x_min = x, y, x+ampx, x-ampx
	end
end

function range(val,⬅️,➡️)
	if(val >= ⬅️ and val <= ➡️)return true
	return 
end

function cool_down(tempo,context)

	if context.val and not context.wait then

		if context.timer>=tempo then
		 context.wait  = true
  	context.timer = 0
 	else		
 		context.timer += 1
 	end
		
	end
	
end

function tool_tip(item)
	--mostrar preco ao passar mouse	
	if slots == 63 then
	 print("you are full",17,120,8)			
		return
	end
	
	if item then
		--nome do item
		if range(item.tip,9,16) then
			print("seeds",17,120,6)			
		else
			print(item.nome,17,120,6)
		end
		--preco
		local cor = status == 2 and 8 or 11
		if(item.val > saldo and status == 2) cor = 2
	 if(item == regador or item == pa)return
  print(item.val,69,120,cor)
	
	elseif(bt_comp:col_mouse("retg") and ls_car.total!=0 and status == 2)then
		local cor = 10
		print("total",17,120,10)
		if(ls_car.total > saldo and status == 2) cor = 2
	 print(ls_car.total,69,120,cor)
	
	--mostrar preco ao passar mouse no carrinho
	elseif ls_car.val then
	
		if ls_car.qual != nil then			
			print(ls_car.qual.item.nome,17,120,6)
	  print(ls_car.qual.item.val,69,120,6)
 	end

	--mostrar saldo 	
	else
		print("money",17,120,6)
		print(saldo  ,69,120,3)
	end
end
-->8
--loljinha =====================
function	des_lojinha()
 --base
	rect(8,2,119,114,5)
	line(92,114,118,114,0)
	--compartimentos			
	rect(37,7,91,28,5)
	rect(32,35,91,55,5)
	rect(42,63,91,83,5)
	rect(47,91,91,114,5)
	
	--linhas do lado labels
	rect(35,30,91,32,5)
	rect(35,31,90,32,0)
	
	rect(45,58,91,60,5)
	rect(45,59,90,60,0)

	rect(50,86,91,88,5)
	rect(50,87,90,88,0)
 
 --tools
 rect(8,2,37,28,5)
 rectfill(9,3,36,27,0)
 rectfill(8,28,91,29,0)
 
 --pots
	local addy = 28
 rect(8,2+addy,32,28+addy,5)
 rectfill(9,36,90,55,0)
 rectfill(8,56,91,57,0)
 
 --plants
 addy +=28
 rect(8,2+addy,42,28+addy,5)
 rectfill(9,64,90,83,0)
 rectfill(8,84,91,85,0)
 
 --flowers
 addy +=28
 rect(8,2+addy,47,28+addy,5)
 rectfill(9,92,90,113,0)
	rectfill(9,112,90,113,0)
	
	--do lado dos labels			
	rect(38,2,39,6,0)
	line(37,8,37,9,0)
	line(32,36,32,37,0)
	line(42,64,42,65,0)
	line(47,92,47,93,0)
	
	--botao de comprar
	rect(92,114,119,126,5)
	rectfill(92,114,118,125,0)
	des_vertices(95,115,22,10,5)
	
	--carrinho de compra
	local y=0
	for i=1,4 do
		rect(95,7+y,116,28+y,5)
		des_vertices(98,10+y,16,16,5)
		y+=28
	end
	
	--precos
 rect(14,117,91,126,5)
 rectfill(15,118,90,125,0)
 rect(14,117,66,126,5)
 
 tools:des()
	pots:des()
 plants:des()
 flowers:des()

	foreach(ls_esp.esps,function(obj) obj:des() end)
	foreach(ls_car.coisas,function(obj) obj:des() end)

 tool_tip(ls_esp.qual and ls_esp.qual.item or nil)
 
 des_bt_comprar()
 bt_volt:des()
 
end

--cria vitrines
function init_loja()

	for i=1,16 do      
  aux      = criar_obj("espaco",1,ls_esp.esps)
		aux.item, aux_tipo, aux.id =  criar_obj("item", aux_tipo), aux_tipo + 1, i

	end	
	
 ondex,ondey =	11,10
 for i in all(ls_esp.esps)do
 	i.x, i.item.x, i.y, i.item.y, ondex = ondex, ondex + 1, ondey, ondey + 1, ondex + 20

		if i.id%4==0 then
			ondey+=28
			ondex =11
		end
	end	
end

--on/off disponibilidade
function toggle_disp(de,ate,qual)
	ate  = ate or de
	qual = qual 
	for i=de,ate do
	 ls_esp.esps[i]:disp_toggle(qual)
	end
end

--desenha o carrinho de compras
function att_car()

	if(#ls_atl.atls == 8) toggle_disp(1)

	if count(ls_car.coisas)>0 then
		local aux_y = 9
		for i in all(ls_car.coisas) do
	 	i.x, i.y, aux_y = 97, aux_y, aux_y + 28
		end	
	end
	
end

function des_bt_comprar()
	rect(bt_comp.x,bt_comp.y,bt_comp.x+bt_comp.w-1,bt_comp.y+bt_comp.h-1,bt_comp.cor1)	
	if(not bt_comp:col_mouse("retg"))then
			buy:des()
	else
		if #ls_car.coisas>0 then
		 buy_atv:des()
		else
			buy:des()
		end
	end
end

function comprar()
	if(#ls_car.coisas+slots > 63) return

	if ls_car.total<=saldo then
		saldo -= ls_car.total	
		ls_car.total	= 0
		
  add_varios_itens(ls_car.coisas,3)
  del_ls(ls_car.coisas)
		return true
	end
	
	return false
	
end
-->8
--inventario ===================
function des_inv()
	if status==3 then
		foreach(ls_inv.coisas,function(obj) obj:des() end)
	else
		foreach(ls_jrd.coisas,function(obj) obj:des() end)
	end
end

function espalhar_pos(ls_doque)

	for i in all(ls_doque)do
		i.x = rnd(112)
	 i.y = rnd(112)
	 n_sai_tela(i)
	end

end

function add_um_item(qual,onde)
	
	if onde   == 1 then
	 qual.onde = 1
	 add(ls_jrd.coisas,qual)

	else
 	def_pos(qual)
	 qual.onde = 2
  add(ls_inv.coisas,qual)
 end
end

function add_varios_itens(qual_ls,onde)
	
	for i in all(qual_ls)do
		add_um_item(i.item,onde)
		local aux = i.item
		i.item.val =	aux.val - ((aux.val*aux.desc)/100)
	end

end



-->8
--menu_de_atalho=================
function init_atl(quantos_pares)	
	local quantos = quantos_pares& ~1

	if(quantos>8) quantos = 8
	if(quantos<2) quantos = 2

	if(#ls_atl.atls+quantos>8)return
	
	for i=1,quantos do
 	new_atl      =	criar_obj("espaco",3,ls_atl.atls)  	 
 	new_atl.item, new_atl.cor1, new_atl.cor2, new_atl.cor3, new_atl.id, new_atl.r = nil, 1, 7, 1, #ls_atl.atls, 8.5

	end

end

function def_pos_atls()

	for i in all(ls_atl.atls)do
  i.x,i.y = 64,64
	end

 local angulo = 0

	local quantos = #ls_atl.atls
 	
	if quantos == 2 then
	 ang_inc,dist = 60,20
	elseif quantos == 4 then
	 ang_inc,dist = 90,20
	elseif quantos == 6 then
	 ang_inc,dist = 60,24
	elseif quantos == 8 then
	 ang_inc,dist = 45,28
	end
	
	for i in all(ls_atl.atls)do
  i.x =	i.x - dist * sin(angulo/360)
	 i.y =	i.y - dist * cos(angulo/360) 
		angulo += ang_inc
	end

end

function des_atl()

	if ls_atl.show then
		for i in all(ls_atl.atls)do
		 ovalfill(i.x-9, i.y-9,i.x+10,i.y+10,0)
   ovalfill(i.x-8, i.y-8,i.x+9 ,i.y+9 ,0)
   oval(i.x-8, i.y-8,i.x+9,i.y+9,i.cor1)

			if i.item !=nil then
			 i.item:des(i.x-7,i.y-7)
			end
 		i:hover("circ")
		end  	
		
  bt_dept:des()
	end

end

--mostrar-ocultar atalhos
function atl_on_off(context,pode_mover)
	pode_mover = pode_mover or false
	if context then
		ls_atl.show = not ls_atl.show 
		
		if ls_atl.show then 
			mouse:reset()
			
			if pode_mover then
				ls_jrd.val,ls_inv.val = true,true
			end
		
			ls_jrd.qual, ls_inv.qual, ls_atl.val, ls_atl.wait, ls_atl.timer, pat_reg.val, pat_sem.val, pa.val = nil, nil, false, false, 0, false, false, false

			foreach(ls_bts,function(obj) obj.wait = false end)

		end
		
	end	
		
end

function toggle_atribuir()
	
	if mouse.esq_press then	
  --oculta os atalhos
	 atl_on_off(true)
	 --poe em contexto de atribuicao
		ls_atl.val = true

		--desativa o movimento do jardim e inventario
		ls_jrd.val,ls_inv.val = false,false				

		if status == 3 then
			if ls_atl.qual and ls_atl.qual.item then
	   mouse:tip_set(ls_atl.qual.item.cur_s,"⬅️","⬆️")
	 	else
	   mouse:tip_set(217,"⬅️","⬆️")
	 	end
	 	
	 else

	 	if ls_atl.qual and ls_atl.qual.item then
	 		local aux_tip = ls_atl.qual.item.tip

	 	 if(range(aux_tip,5,8)) mouse:tip_set(ls_atl.qual.item.cur_s,"⬅️","⬆️")
			 
			 if range(aux_tip,9,16) then
			  mouse.s = 228
			 end
			 
		 	if aux_tip == 17 then
	 			mouse.w,mouse.h = 16,16
		 		mouse.s = 204
		 		
		 	elseif aux_tip == 18 then
  			mouse.ct,mouse.w,mouse.h,mouse.s,mouse.ax,mouse.ay= 9,16,16,238,-2,-14
		 	end
	 	end
	 	
	 end
	end								
end

function funcionalidades(que_func,container)
	--se nao tem atalho selecionado
	if(not ls_atl.qual) return

 --tipo item do atalho
 local aux_tip = nil
	if(ls_atl.qual.item)aux_tip = ls_atl.qual.item.tip

	--que func == 1 permutar item com atalho
	if    (que_func == 1)then
	 -- o atalho selecionado
		-- ja tem  um item?

		-- se ele ja tiver efetuamos
		-- uma troca com o jardim/inv
		if aux_tip then
	  atl_para_container(mouse.esq,container,true)
  -- se ele nao tiver simplesmenete
  -- bota no atalho
 	else
   container_para_atl(mouse.esq,container)
	 end	
					 
	--que func == 2
	elseif que_func == 2 then
		-- mesma logica da funcao 1
		-- exclusivo pro jardim
		-- so vasos pode ser colocados
		-- so vasos sem planta podem ser removidos
		-- as demais coisas executam suas respectivas funcoes
	
	 --nao tem item
 	if not aux_tip then
 	 --o item a ser guardado eh um vaso sem planta
			if(container.qual and range(container.qual.tip,5,8) and container.qual.algo==0 and not container.qual.planta and not(pat_sem.val or pat_reg.val))then
 	  container_para_atl(mouse.esq,container)
 	 end
 	 
		--eh um vaso
 	elseif range(aux_tip,5,8) then
			--o que vai ser permutado  um vaso sem nada?
			if container.qual and container.qual.algo == 0 then
		  atl_para_container(mouse.esq,container,true)
		 else
		  atl_para_container(mouse.esq,container,false)
		 end
				
 	--eh um upgrade de atl
 	elseif aux_tip == 1 then
	 	if mouse.esq then
		 
				if #ls_atl.atls == 8 then
				 toggle_disp(1)
				else
					init_atl(2)
	 		 def_pos_atls()
				 ls_atl.qual.item = nil
			 	if(#ls_atl.atls == 8) toggle_disp(1)
				end
				ls_atl.qual = nil
	   atl_on_off(true)	   
			end
			
	 --eh uma semente
	 elseif(range(aux_tip,9,16))then
			pat_sem.val = true		

		--eh um regador
		elseif aux_tip == 17 then
			pat_reg.val = true
  --eh uma pa
 	elseif aux_tip == 18 then
			pa.val = true
		end
			 
	end
	
end

--[[
	troca de luagres o item do atalho
	atua com algum do inventario que
	for clicado	
]]
function atl_para_container(context,qual_container,permutavel)
	permutavel = permutavel or false	

	if qual_container.qual and permutavel then
	 mouse:tip_set(ls_atl.qual.item and 233 or 217,"⬅️","⬆️")		
 else
	 mouse:tip_set(ls_atl.qual.item.cur_s,"⬅️","⬆️")
 end
	 
	if context then
		--seta a proprieda onde
		--para o container
		--jardim ou deposito
		
		ls_atl.qual.item.onde     = status==1 and 1 or 2
	 ls_atl.qual.item.qual_atl = 0

		--se algo do container
		--nao esta sendo selecionado
		--poe na posicao do cursor ajustado
		if((qual_container.qual and not permutavel) or not qual_container.qual)then
			ls_atl.qual.item:mov(stat(32)-11,stat(33)-15)	
	 	--adiciona ao container
			add(qual_container.coisas,ls_atl.qual.item)

 		--esvazia o atalho
 	 ls_atl.qual.item = nil

		 qual_container.val  = true
   qual_container.wait = false
   ls_atl.qual = nil
   ls_atl.val = false
   mouse:reset()
   
  --se algo do container
		--esta sendo selecionado
		--permuta esse "algo" com
		--o item do atalho		
		else
		 --poe o item do atalho na mesma posicao do item selecionado
			ls_atl.qual.item:mov(qual_container.qual.x,qual_container.qual.y-2)	
			--add o item do atalho no container
			add(qual_container.coisas,ls_atl.qual.item)
 		--remove o item selecionado do container e passa pro atalho
 		ls_atl.qual.item         = del(qual_container.coisas,qual_container.qual)
		 ls_atl.qual.item.onde    = 3
			ls_atl.qual.item.qual_atl = ls_atl.qual.id
		
			qual_container.val  = true
   qual_container.wait = false
  	atl_on_off(true)
  	  	  	
		end
	end
end

function container_para_atl(context,qual_container)
	--se algo do container esta sendo selecionado		
	if qual_container.qual and context then
		local para_atl        = qual_container.qual
  para_atl.onde = 3
		ls_atl.qual.item      =	del(qual_container.coisas,para_atl)
  ls_atl.qual.item.qual_atl = ls_atl.qual.id
		ls_atl.qual           = nil
		ls_atl.val            = false
		qual_container.val    = true
  qual_container.wait   = false

 	atl_on_off(true)
	end
end
-->8
--deposito======================
function des_depot()
 --base
	rect(107,3,119,115,1)
	rect(8,3,107,115,4)
	--pesinhos
	rect(16 ,118,28 ,122,1)
	rect(8  ,118,16 ,122,4)
	rect(107,118,119,122,1)
	rect(99 ,118,107,122,4)
	line(8  ,118,119,118,0)
	
	--pregos frente
	local aux_1,aux_2 = 6,0
 for i=1,3 do
	des_vertices(11,aux_1,94,26,1)
		aux_1 += 53
	end
	--pregos laterais
	aux_1 = 11
	for i=1,4 do
		des_vertices(109,aux_1,9,20,1)
		aux_1 += 26
	end
		
 --prateleiras
	aux_1 = 11
	aux_2 = 32
	for i=1,4 do
		rect(16,aux_1,28,aux_2,1)
		rect(16,aux_1,95,aux_2,4)
		aux_1+= 24
		aux_2+= 24
	end
	
	des_prateleiras(16,32,24)
 bt_vend:des()

	if venda then

		if venda_timer<30 then
	 	venda_timer +=1
	 else
 	 pisca = not pisca
	 	venda_timer = 0
	 end

	 bt_vend:des(bt_vend.x,bt_vend.y-1)
 	pal(1,0)
 	
		if(pisca)then pal(11,5) else pal(5,11) end
	 spr(247,121,109)
	 pal()
		rect(14,117,91,126,5)
 	rectfill(15,118,90,125,0)
	 rect(14,117,66,126,5)
	 
  tool_tip(ls_inv.qual)
  
	else
	 bt_vend:des()
		pal(11,5)
		pal(1,0)
		pal(7,13)
		pal(3,1)
	 spr(247,121,110)

	end
 pal()

	des_inv()

end

function des_prateleiras(x_init,y_init,y_esp) 

	aux_y = y_init
	for i in all(ls_prt)do
		i.x  = x_init
	 i.y  = aux_y
  rect(i.x,i.y,i.x+i.w-1,i.y+i.h-1,4)
		aux_y += y_esp
	end
	
end

function init_prat()
	for i=1, 4 do
		criar_obj("prateleira",0,ls_prt)
	end	
end

function grav_depot()

	for i in all(ls_inv.coisas) do
		it={
			x = i.x+i.xoff,
			y = i.y+14,
			h = 1,
			w = i.woff,
			xoff = 0,
			yoff = 0,
			woff = 0,
			hoff = 0,	
		}		
		if(
			not	col_2ret(it,ls_prt[1])and
			not	col_2ret(it,ls_prt[2])and
			not	col_2ret(it,ls_prt[3])and
			not	col_2ret(it,ls_prt[4])
		)then
			i.y +=grav
			n_sai_tela(i)	
		end	
	end
	grav = 2
end

function def_pos(i)
		i.x = flr(rnd(60)) + 16 
		
		if i.tip <=4 then
			i.y = 16 
		elseif i.tip<=8 then
			i.y = 40
		else
			i.y = 64
		end

end


-->8
--jardim =======================
function des_jardim()
 des_inv()
end

function plantar(o_que)

 if(#pat_sem == 0) return 
	ls_jrd.coisas.wait = true
 local	qual_vaso = get_obj_by_col_retg(ls_jrd.coisas,o_que)
	if(qual_vaso and qual_vaso.planta)return
	
	if qual_vaso then
		qual_vaso.planta  = o_que.ls_aux.fases
  qual_vaso.estagio, qual_vaso.algo, ls_atl.val, pat_sem.val, ls_atl.wait, ls_jrd.val = 3, 1, false, false, false, true
 	mouse:reset()
  o_que:del()
 end
 
end

function remov_planta()
	qual_vaso = ls_jrd.qual
	if qual_vaso and qual_vaso.planta then
		qual_vaso.planta,qual_vaso.algo = nil,0
 end
 
end

function regar(o_que)

	if(#pat_reg == 0) return 
	qual_vaso = get_obj_by_col_retg(ls_jrd.coisas,o_que)
	
	if qual_vaso then
		if(not qual_vaso.colher and qual_vaso.saturac < max_saturac) qual_vaso.saturac += 1
	 o_que:del()
 	if qual_vaso.saturac >= max_saturac then
 		qual_vaso:vasar()
			avancar_fase(qual_vaso)
			qual_vaso.saturac=0
		end
		if(qual_vaso.colher)qual_vaso:vasar()
		
 end
   
end

function avancar_fase(o_que)
 if(not o_que.planta) return
	local inc = 1 --flr(rnd(100))
	o_que.estagio+= inc%2
 if o_que.estagio >#o_que.planta then
  o_que.estagio = #o_que.planta
  o_que.colher  = true
 end
end

-->8
--save/load =======================
function save_obj(obj,qual_slot)

	if(not obj or not obj.onde or obj.onde == 0) return
	local combinado = 0
	--garantir cordenada dentro do range 
	local x_aux = obj.x<0 and -obj.x or 0
	local y_aux = obj.y<0 and -obj.y or 0

	if(x_aux != 0) cu3 = x_aux

	--salvar informacoes basicas
	combinado |= (obj.onde    & 0x03) << 14
	          | ((obj.x+x_aux & 0x7f) <<  7)
		         |  (obj.y+y_aux & 0x7f) 
	          |  (obj.tip-1   & 0x1f) >>> 5
	          |  (obj.algo    & 0x0f) >>> 6
	
	--o item tem uma planta?
 if(range(obj.tip,4,8) and obj.algo==1 and obj.planta)then
  combinado |= (obj.planta.tip-9  & 0x7) >>> 9
  combinado |= (obj.estagio       & 0x7) >>> 12
 end
 

 --esta em um atalho?
 if(obj.onde == 3)	combinado |= (obj.qual_atl & 0x7) >>> 15
	
	dset(qual_slot,combinado)	
	return obj
	
end

function save_game()
 del_ls(cu4)
 --salvar variaveis de jogo
	local game_vars = 0
	game_vars |= (saldo    & 0xfff) <<  4 --saldo
	          |  (stat(90) & 0x7ff) >>> 7 --ano
		         |  (stat(91) & 0xf  ) >>>11 --mes
	          |  (stat(92) & 0x1f ) >>>16 --dia

 dset(0,game_vars) 
 
 --objetos funcionais padrao		
	save_obj(regador,1)
	save_obj(pa     ,2)
 --salvar objetos
 local slot = 3

	for i in all(ls_inv.coisas)do
		if i != regador and i != pa then
 		if(save_obj(i,slot))	slot+=1 
		end
	end	 
	
	for i in all(ls_jrd.coisas)do
		if i != regador and i!= pa then
 		if(save_obj(i,slot))	slot+=1  
		end
	end

	for i in all(ls_atl.atls)do
		if i.item then
			if i.item != regador and i.item != pa then
 			if(save_obj(i.item,slot))	slot+=1 
			end
		end
	end	 

	slots = slot-1
	if(slot < 63)	for i=slot,63 do dset(i,0) end

end

function load_obj(qual_slot,guardar_em_ls)
 guardar_em_ls = guardar_em_ls or true
	local save = dget(qual_slot)
	
 local onde =  (save >>> 14) & 0x03
	if(onde == 0) return
 local x    =  (save >>>  7) & 0x7f
 local y    =  (save >>>  0) & 0x7f
 local tip  = ((save <<   5) & 0x1f)+1
	local algo =  (save <<   6) & 0x01

	--o item basico
	local novo_obj = criar_obj("item",tip,nil,nil,x,y,onde)
 novo_obj.algo  = algo
 
 --o item tem uma planta?
 if(range(tip,4,8) and algo==1)then
  local tip_pla    = ((save << 9) & 0x07)+9
  local pla_salva  = criar_obj("item",tip_pla)

  novo_obj.planta  = pla_salva.fases
 
  novo_obj.estagio = ((save << 12) & 0x07)
 end
 
 if guardar_em_ls then
	 if(onde == 1) add(ls_jrd.coisas,novo_obj)
	 if(onde == 2) add(ls_inv.coisas,novo_obj)
	 if(onde == 3) then
	  novo_obj.qual_atl = (save << 15) & 0x7
			ls_atl.atls[novo_obj.qual_atl].item = novo_obj		
	 end 	
	end
 return novo_obj
 
end

function load_game()
 load_aux = dget(0)
	--primeiro carregar o saldo
 saldo = (load_aux >> 04)&0xfff

	--objetos padro
 regador =	load_obj(1) or criar_obj("item",17,ls_inv.coisas,nil,16,18,2)
 pa      = load_obj(2) or criar_obj("item",18,ls_inv.coisas,nil,32,18,2)

 --careggar regador e pa	
	for i=3, 63 do
  if(not load_obj(i)) break
 end
 
end

function debug_obj(obj,cor)

 if(true) return
	cor = cor or 9
 if(not obj)  return
 
	--keys basicas
	local ls_keys = {"onde", "x", "y","tip","algo","qual_atl"}
	print("")
	print("")
	print("")

	--salvar infomacoes bases
	for v,k in pairs(ls_keys)do
		--primeiro cropar os bits extras que possam existir
		print(k..":"..tostr(obj[k]),cor)		
	end
	--informaes especificas
	--tem algo 
	if obj.algo == 1 then
  --eh algo que pode ter uma planta
		if(range(obj.tip,4,8))then

			if obj.planta then
	 		print("planta: "..obj.planta.tip)
 			print("estagio:"..obj.estagio)
 		end
		end
		--eh algo que pode ter uma capacidade
		if(range(obj.tip,1,3))then
 		print("capacidade:"..obj.planta.tip)
		end
	end

end


__gfx__
880008888880008800000000000bbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
888080000008088800000422200b1b00000000000000000000005577777000000000004224000000000000000000000000000000000000000110000000000000
0888000000008880000441111bbb1bbb000000000000000000005566666000000000049119400000000066666660000000000000000000001551111111111100
0088800000088800004111111b11111b0000000000000000000000d666d000000000024994209000000611111116600000000000000000001555555555555510
0208880000888080041111111bbb1bbb00000000000000000000055ddd0000000000002112090000006111111161150000000500000000000151111111111510
200088800888000804111999111b1b0044000000000000440000560dd0000000000000999929900000f1111111f1150000005555555000000151551551551510
800008880880000800411a19114bbb00414000000000041400006060060000000000041111400000000fffffff11150000055555555500000151111111111510
8000008880000008021411a11411111024122244442221420000070000600000000004111140000000d1111111d1150000005555555500000151155155115100
8000000888000008021141114121112002911111111119200000070bb0600000000041113314000000d1bb1bb1d1150000000500001500000151111111115100
20000220888000080411144411211120021999999999922000007033330d00000004111bb311200000611bbb1161150000000000011100000155555555551000
200022200888000804111111114111200241414141414120000703b33b30d00000411113b1111200006111311161150000001111111000000151111111111000
02022200008880800411111111411120021414141414142000060333bbb0d0000041113111111200006111311161150000001111110000000155555555555100
00222000000888000041111114111200002121212121220000006000000d00000004111111112000006111111161150000000000000000000015511115511000
022200000000888000044444422220000002222222222000000006666dd00000000044444222000000066666666dd00000000000000000000015510015510000
22202000000208880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001100001100000
22000222222000880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000111111111100000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000001444466444410000000000000000000110000000000000
0000000000000000000000000000000000000dddddd00000000dddddddddd0000011111111111100011111111111111000000000000000001771111111111100
000000000000000000000000000000000000d122221d000000d1111111111d000114444664444110019999977999991000000700000000001777777777777710
00000000000000000002444444442000000061222216000000d1122222211d000144444664444410011111177111111000007777777000000171111111111710
00224444444422000021111111111200000016666661000000612222222216000144444664444410011111111111111000077777777700000171771771771710
00211111111112000041414121411400000001111110000000166666666661000144444664444410011122222222111000007777777700000171111111111710
0041414121411400004112141214140000000d1111d00000000d11111111d0000111111661111110011122222222111000000700005700000171177177117100
00411214121414000091214141411900000066dddddd00000066dddddddddd000141416666141410019191777719191000000000055500000171111111117100
00912141414119000009999999999000000d66dddd6dd0000d66d6dd6ddd6dd00141416116141410019191711719191000005555555000000177777777771000
009999999999990000011111111110000001ddddd666100001ddddddd6d666100141441661441410019199177199191000005555550000000171111111111000
0002111111112000000024422222000000011ddddd6110000111dd6ddddd61100141444444441410019199999999191000000000000000000177777777777100
00022444422220000000244222220000000011111111000000111666111111000141444444441410019199999999191000000000000000000017711117711000
0002244442222000000004422220000000000111111000000001116111d110000141111111111410019111111111191000000000000000000017710017710000
00000000000000000000000000000000000000000000000000000000000000000144444444444410019999999999991000000000000000000001100001100000
00000000000000000000000000000000000000000000000000000000000000000111111111111110011111111111111000000000000000000000000000000000
00000000000000000000000000000000000b03000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000b0bbb30b000000000000000000b0b000000000000000000000000000000000000000000000000000000000000000000
000000000000000000bb30000bbb300000bbbbb30b330b000000000000003000000000000bb00000000000000000000000000000000000000000000000000000
00000000000b300003bbb100bbbbb10000bbbbbbbbb330000000000000b0bb000000bb00b000000000000000000000000000000000000000000000b033000000
0000000000bbb3000bbbb100bbbbb13000bbbbbb3b3330000bb0bb00000b00000000030300bb0000000000000000000000000000000000000000000b30000000
0000b00000bb33000bbb3100bbbb3133003bbbb33333300000b330000b33bb00000bb03a0bb000000003300000000000000a9000000000000000003bb3000000
000b330000b3310003b331003bb331330003bb3313330000000300000003300000000a00300bb00000033300000000000009a300000000000000031331300000
000111000001100000331000033310000000333100000000001111000011110000000000b300000000000b000000000000000b00000000000000b131331b0000
0000000000003000000000000000000000000000000000000000000000000000000b300b30a00000003030b0b4000000009040b049000000000031b1bb130000
000000000003b0000000000000000000000000000000000000000000000000000000033b00000000030bbb304b3304b00a0bbb30943304900033313133133300
00000000003b310000000000000000000000a0000000000000000000000000000000b00b000bb00000bbb3b333333b4000bbb3b3133339400003113133113000
003003000013110000000000000000000a9aa9a0000000000bb0000000000000000b0a0333b000000bbbbb33bbb333000bbbbb33bbb1130000bbb111311bbb00
0003300000011000000000000000b00009a24a900000bb00b0000000000000000000000330bb00000b3bbbb13b3333000b3bbbb13b311300000bb31bb13bb000
00bb100000b31300000000000b3bb3b0aa2424a00000030300bb000000000000000000033000000003b3bb311333310003b3bb31133331000000113bb3330000
00013300000110000000000003b2ab300a4242aa000bb0330bb0000000b00b000000000330000000003bb33103331000003bb3310333100000000113b1100000
0031100000311300000bb000bb242ab009a42a9000000000300bb0000bb0b0000000001111000000000333100000000000033310000000000000000000000000
000000000000000000b33b000ba242bb0a9aa9a000000000b3000000000030000000000000000000000000000000000000000000000000000000000000000000
00000000000000000b3423b003ba2b300001a000000b300b3000000000b0b3000000000000000000000000000000000000000000000000000000000000000000
00000000000000000b3243b00b3bb3b000b313300000033b00000000b00b30b0000000000bb00000000000000000000000000000000000000000000000000000
000000000000000000b33b000001b1000bbb13000000b00b000bb0000b3b00000000bb00b00000000000000000000000000003b30b30000000000000b0000000
0000000003000030000bb00000b31bb000033bb0000b000333b00000000b00b00000030300bb0000000000b0330000000000303bb303000000000b3bb3b00000
00b11300033103300bb31bb00bbb3bbb00031bbb0000000330bb000000033b00000bb0382bb000000000000b3000000000000003b0000000000003bddb300000
003b33000b111b300031110000311100003111000000000330000000000330b000008202800bb0000000003bb300000000000cc33cc000000000bb0d90b00000
0001100000b3b30003131330031313300313133000000011110000000011110000002800b382000000000333333000000000c7cccc7c000000000b4009bb0000
0000000000000000000000000000000000000000000000133300000000000000000b300b302800000000b333333b00000000cc7777cc0000000003b49b300000
000000000000000000000000000000000000000000000b3133b30000000000000000033b0000000000303b3333b303000300dccccccd003000000b3bb3b00000
0000000000033000000000000003301331033000000331bbbb133000000000000000b82b000bb000003313bbbb31330000331dddddd1330000000001b1000000
0000000000322300300110030000113333110000000011313311000000000000000b028b33b000000003113333113000000311dddd113000000000b31bb00000
00000000b0b22b0b13133131000bb111111bb000000bb111111bb000000000000000000330bb000000bbb111111bbb0000bbb112211bbb0000000bbb3bbb0000
00bb3000b00bb00bb111111b0000b31bb13b00000000b31bb13b0000000000000000000330000000000bb31bb13bb0000b0bb31bb13bb0b00000003111000000
00b22300033333303b1bb1b30000113bb33300000000113bb33300000000000000000003300000000000113bb33300000000113bb33300000000031313300000
0031130000311300013bb31000000113b110000000000113b110000000000000000000111100000000000113b110000000000113b11000000000000000000000
0000000000000000000000bbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a00000000
00000000000b3300000000b22b0bb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000090aa00000000
0000000000b03300000bb0322332b0000000000000000000000000b000000000000000000000000000000000000000000000000000000000000099aa99900000
000000000b300000000b230bb232b0000000000000000000000000bb000000000000b0000bbb00000000000000000000000000000000000000009adda9000000
0bb030000033b000000b23b22b2230000000000000000000000000b2b0000000000b0bb033b000000000000000000000000000300000000000aa0ddd0aa00000
000b0000000b00000000323223230000000000bbb0000000000000b22b00b0000000000b3000000000000000000000000000000b30000000000a90009aaa0000
0000b0000000b0000000032222300000000000b22b000000000b0032230bb0000000003bb30000000000000000000000000000b000f0f0000000a909a9000000
00031130000311300000311111130000000000b22b0bb000000bb0122232b0000000092332900000000000b003bb000000000b000f0f0f00000999aa99000000
00000000000000000000000300000000000bb0322332b000000b2312b232b0000000a292992a000000000b00333bb00000000300f07070f00000001a190bb000
0000000000000000000000b09a000000000b23222232b000000b232b2b323000000092a2aa29000000000300b3b3b300000bb3000f070f00000bb00110bb3300
000000000000000000000b09a9a00000000b232bbb323000000b232b2b3230000033929299293300000bb300bb300300000033006060606000bbbb3013330030
00000000000000000000030a9a900000000b23b22b223000000322b22b223000000322929922300000003bb00bb0300000000bb00606060000003bb313000000
0000000000000000000bb300a90000000003223223223000000322322322300000bbb222922bbb0000000b000033000000000b00006060000000000310000000
000000000000000000000bb00000000000003232232300000000323223230000000bb32bb23bb000000030b000000000000030b0000000000000003111000000
00000000000000000000000b00000000000003222230000000000322223000000000113bb33300000000000b000000000000000b000000000000031313300000
000000000000000000000311113000000000311111130000000031111113000000000113b1100000000003111130000000000311113000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bb00b300000
0000000000000000000000000000000000000000000888000000000000000000000000000000000000003330000000000000b0000bbb00000000bbbb03330000
000000000000000000000000000000000000000088822280000000000000000000000000000000000000033000000000000b0bb033b000000000000b30000000
000000000000000000000000000000000008000082288280000000000000000000000033033000000000000b300000000000000b300000000000088338800000
00000000000000000000000000030000008280000822280000000000000000000000000b30000000000000b000a0a0000000003bb30000000000878888780000
000000000000000000000000003230000b424b000b888b0000000000000000000000003bb300000000b00b000a0a0a0000000a9339a000000000887777880000
0000000000000000000300000bb2bb0000bb300000bb30000000000000000000000003133130000000bb0300a07070a0000079a9aa9700000030288888820300
00000000000000000bb2bb0000bb3000000300000003000000000000000000000000b131331b0000000bb3000a070a000000a979779a00000033122222213300
000000000bb0bb0000bb3000000300000bb300000bb300000000000000000000000031b1bb13000000003300909090900033a9a9aa9a330000b3112222113b00
0000000000bb3000000300000bb30000b0033300b00333000000000000000000003331313313330000000bb009090900000399a9aa99300000bbb11b111bbb00
0bb0bb00000300000bb30000b003330000330030003300300000000000000000000311313311300000000bb00090900000bbb999a99bbb00000bb31bb13bb000
00b3300000b3000000033300003300300003b0000003b000000000000000000000bbb111311bbb00003330b000000000000bb39bb93bb0000000113bb3330000
0003000000033000003300000003b00000330b0000330b000000000000000000000bb31bb13bb0000003300b000000000000113bb33300000000011111100000
00030000000300000003000000330000000300000003000000000000000000000000113bb3330000000003333330000000000113b11000000000000000000000
001111000011110000111100001111000011110000111100000000000000000000000113b1100000000000000000000000000000000000000000000000000000
55550000555500005500000055550000000000000000000000000000000030000000000000000000000000000b03300000000000000000000000000000000000
0550000055050000550000005505000000000000009000090bbb0b3000bb3b300090a00000000bbb0088828000b0077000000000000000000999999000000000
0550000055050000550000005555000000bb03300009b039b003b3000003b3000099aa990000b0b3002000200b007066000000000000000009666d5900000000
05500000555500005555000055050000008b3320000b303300943490007c3c6000a24290000b0b03000288000b00600600000000000000000961111590000000
0000000000000000000000000000000008888882090000000a4949490cc766dd0aa424aa0bb0b03000008000030006600000000000000000096155d159000000
0000000000000000000000000000000008e8888200930bb30a4a4a490cccccdd009242a00b0b030000bbb33000300000000000000000000009d1511d90000000
0000000000000000000000000000000008ee882800330bb3094949490cdcdddd099aa9900300b0000003b0000003300000650006666607000951d15900000000
0000000000000000000000000000000000882280000003330094949000cdcdd00000a0900333b0000000330000000000065700665557607000951d9d90000000
55550000555500005555000055550000811111110ddd0000004444000000000000444400001111000000000000000000057500761117706000095909d9000000
5505000055550000550000005550000017777771d776d00004111140000000000004200e111bb11100000000000000000005605777775060000090009d999990
5555000055050000555000005500000016111710d7dd6d00419911420000000000eeeee01bbbbbb1000000000000000000005655555550500000000009624490
550000005505000055000000555500001611710056d7d50044114412400000040041120e01bbbb10000000000000000000000555675655000000000009200290
0000000000000000000000000000000016161610056d70004144121224242424041131201c1bb1c1000000000000000000000055675650000000000009402900
0000000000000000000000000000000016616671005506444111141222424242041311201c1111c1000000000000000000000005665600000000000009429000
00000000000000000000000000000000161017710000020441114112242424220411112001cccc10000000000000000000000000000000000000000009990000
00000000000000000000000000000000110001110000042204442220022222200044220000111100000000000000000000000000000000000000000000000000
55550000555000005505000055550000011111000dddd0000000000000bbbb001111111111111111000000000000000000000000000000000000000000000000
5505000050550000550500000550000016777611057650000000000000b11b00188118811bbbbcc1000000000000000000000000000000000000000009990000
5550000055050000555500000550000077777777576dd50044444222bbb11bbb188828811b111cc1000000000000000000000000000000000000000009429000
550500005555000055550000555500006776777655d7bdd041111112b111111b11888211bbb11181000000000000000000000000077700000000000009402900
0000000000000000000000000000000067611766005b7bbd44444222b111111b112888111b111888000000000000000000000000700060000000000009200290
00000000000000000000000000000000761766110053bbbd01111110bbb11bbb1882888114411181000000000000000000000006677005000000000009624490
0000000000000000000000000000000017171100000533350211112000b11b00188118811448888100000000000000000000006556750500000090009d999990
0000000000000000000000000000000001110000000555550244422000bbbb0011111111111111110000000000000000000006511675500000095909d9000000
55550000500500005505000055550000777000007707000077070000011bb1100000000000dddd000000000000000000000006516755650000951d9d90000000
555000005505000055050000550000007077000077070000770700001bb77bb1000006600d111dd0000000000000000000000677757556000951d15900000000
055500005555000055550000550000007707000077770000777700001bb331b1d600600dd6666d150000000000000000000000655667500009d1511d90000000
5555000055550000055000005555000077770000777700000770000001b7b11066ddd00dd1111d1500000000000000000076000555660000096155d159000000
00000000000000000000000000000000000000000000000000000000011b7b100d61160dd1bb1d15000000000000000000675555555000000961111590000000
000000000000000000000000000000000000000000000000000000001b133bb10d166160d1bb1d150000000000000000005650000000000009666d5900000000
000000000000000000000000000000000000000000000000000000001bb77bb10d111160d1111d15000000000000000000000000000000000999999000000000
00000000000000000000000000000000000000000000000000000000011bb11000dddd000ddddd50000000000000000000000000000000000000000000000000
__label__
ccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000660600006606660066000006000666000606000666
c0c00000000000000000000000000000000000000000000000000000000000000000000000000000000006000600060600600600006006000006006006000006
c0c00000555555555555555555555555555555005555555555555555555555555555555555555555555556665655565655655666555556665666556506660666
c0c00000500000000000000000000000000005000000000000000000000000000000000000000000000000060600060600600006006006060600006506060600
ccc00000500555505555055550550005555005000000000000000000000000000000000000000000000006600666066000600660000006660666060506660666
00000000500055005505055050550005550005000000000000000000000000000000000000000000000000000000000000000000000000000000000500000000
55500000500055005505055050550000555005000000000000000000000000000000000000000000000000000000000000000000000000000000000500000000
50500000500055005555055550555505555005555555555555555555555555555555555555555555555555555555000555555555555555555555500500000000
50500000500000000000000000000000000000000000000000000000000000000000000000000000000000000005000500000000000000000000500500000000
50500000500000000000000000000000000000000000000000000000000000000000000000000000000000000005000500000000000000000000500500000000
55500000500111111111111111111001111111111111111110011111111111111111100111111111111111111005000500500000000000000500500500000000
00000000500110000000000bbb011001100000000000000110011000000000000001100110000000000000011005000500000000000000000000500500000000
55500000500100800422200b0b001001008000422400000010010080557777700000100100800000000000001005000500000000000000000000500500000000
505000005001008840000bbb0bbb1001008804900940000010010088556666600000100100880000000000001005000500000000000000000000500500000000
505000005001008880000b00000b100100888249942090001001008880d666d00000100100888000000000001005000500000000000000000000500500000000
505000005001040888000bbb0bbb1001000888200209000010010008885ddd000000100100088800000000001005000500000000000000000000500500000000
55500000500104008889000b0b001001000088899929900010010000888dd0000000100144008880000000441005000500000000000000000000500500000000
00000000500100400888004bbb001001000008880040000010010000688806000000100140400888000004041005000500000000000000000000500500000000
00000000500102040088840000001001000004888040000010010000078880600000100124022288842220421005000500000000000000000000500500000000
00000000500102004008882000201001000040088804000010010000070888600000100102900008880009201005000500000000000000000000500500000000
000000005001040004448880002010010004000b88802000100100007033888d0000100102099999888992201005000500000000000000000000500500000000
0000000050010400000008880020100100400003b88802001001000703b33888d000100102404040488840201005000500000000000000000000500500000000
000000005001040000000088802010010040003000888200100100060333bb888000100102040404048884201005000500000000000000000000500500000000
00000000500100400000040888001001000400000008880010010000600000088800100100202020202888001005000500000000000000000000500500000000
0000000050010004444442228800100100004444422288001001000006666dd08800100100022222222288001005000500000000000000000000500500000000
00000000500100000000000008001001000000000000080010010000000000000800100100000000000008001005000500500000000000000500500500000000
00000000500110000000000000011001100000000000000110011000000000000001100110000000000000011005000500000000000000000000500500000000
00000000500111111111111111111001111111111111111110011111111111111111100111111111111111111005000500000000000000000000500500000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555555555555555555555500500000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000500000000
00000000555555555555555555555555500555555555555555555555555555555555555555555555555555555555000000000000000000000000000500000000
00000000500000000000000000000000500000000000000000000000000000000000000000000000000000000005000000000000000000000000000500000000
00000000500555505555055550555500500000000000000000000000000000000000000000000000000000000005000000000000000000000000000500000000
00000000500550505505005500555000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000500000000
00000000500555505505005500055500500000000000000000000000000000000000000000000000000000000000000000000000000000000000000500000000
00000000500550005555005500555500555555555555555555555555555555555555555555555555555555555555000555555555555555555555500500000000
00000000500000000000000000000000000000000000000000000000000000000000000000000000000000000005000500000000000000000000500500000000
00000000500000000000000000000000000000000000000000000000000000000000000000000000000000000005000500000000000000000000500500000000
00000000500111111111111111111001111111111111111110011111111111111111100111111111111111111005000500500000000000000500500500000000
00000000500110000000000000011001100000000000000110011000000000000001100110000000000000011005000500000000000000000000500500000000
00000000500100800000000000001001008000000000000010010080000000000000100100800000000000001005000500000000000000000000500500000000
000000005001008800000000000010010088000000000000100100880dddddd0000010010088ddddddddd0001005000500000000000000000000500500000000
000000005001008880000000000010010088800000000000100100888100001d000010010088811111111d001005000500000000000000000000500500000000
00000000500100088800000000001001000888444444200010010008880000160000100100d8880000011d001005000500000000000000000000500500000000
00000000500100228884444422001001002088800000020010010000888666610000100100618880000016001005000500000000000000000000500500000000
00000000500100200888000002001001004048882040040010010000088811100000100100166888666661001005000500000000000000000000500500000000
000000005001004040888040040010010040028882040400100100000d8881d000001001000d11888111d0001005000500000000000000000000500500000000
0000000050010040020888040400100100902048884009001001000066d888dd000010010066ddd888dddd001005000500000000000000000000500500000000
0000000050010090204088800900100100099999888990001001000d66dd888dd00010010d66d6dd888d6dd01005000500000000000000000000500500000000
00000000500100999999988899001001000000000888000010010001ddddd8881000100101ddddddd88866101005000500000000000000000000500500000000
000000005001000200000088800010010000244222888000100100011ddddd88800010010111dd6ddd8881101005000500000000000000000000500500000000
00000000500100022444422888001001000024422228880010010000111111188800100100111666111888001005000500000000000000000000500500000000
0000000050010002244442228800100100000442222088001001000001111110880010010001116111d188001005000500000000000000000000500500000000
00000000500100000000000008001001000000000000080010010000000000000800100100000000000008001005000500500000000000000500500500000000
00000000500110000000000000011001100000000000000110011000000000000001100110000000000000011005000500000000000000000000500500000000
00000000500111111111111111111001111111111111111110011111111111111111100111111111111111111005000500000000000000000000500500000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555555555555555555555500500000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000500000000
00000000555555555555555555555555555555555550055555555555555555555555555555555555555555555555000000000000000000000000000500000000
00000000500000000000000000000000000000000050000000000000000000000000000000000000000000000005000000000000000000000000000500000000
00000000500555505500055550555505555055550050000000000000000000000000000000000000000000000005000000000000000000000000000500000000
00000000500550505500055050555500550055500050000000000000000000000000000000000000000000000000000000000000000000000000000500000000
00000000500555505500055550550500550005550050000000000000000000000000000000000000000000000000000000000000000000000000000500000000
00000000500550005555055050550500550055550055555555555555555555555555555555555555555555555555000555555555555555555555500500000000
00000000500000000000000000000000000000000000000000000000000000000000000000000000000000000005000500000000000000000000500500000000
00000000500000000000000000000000000000000000000000000000000000000000000000000000000000000005000500000000000000000000500500000000
00000000500111111111111111111001111111111111111110011111111111111111100111111111111111111005000500500000000000000500500500000000
00000000500110000000000000011001100000000000000110011000000000000001100110000000000000011005000500000000000000000000500500000000
00000000500100800000000000001001008000000000000010010080000000000000100100800000000000001005000500000000000000000000500500000000
00000000500100886666666000001001008866666660000010010088666666600000100100886666666000001005000500000000000000000000500500000000
00000000500100888000000660001001008880000006600010010088800000066000100100888000000660001005000500000000000000000000500500000000
00000000500100688800006005001001006888000060050010010068880000600500100100688800006005001005000500000000000000000000500500000000
00000000500100f0888000f00500100100f0888000f00500100100f0888000f00500100100f0888000f005001005000500000000000000000000500500000000
000000005001000ff888ff0005001001000ff888ff0005001001000ff888ff0005001001000ff888ff0005001005000500000000000000000000500500000000
00000000500100d0008880d00500100100d0008880d00500100100d0008880d00500100100d0008880d005001005000500000000000000000000500500000000
00000000500100d0bb0888d00500100100d0bb0888d00500100100d0bb0888d00500100100d0bb0888d005001005000500000000000000000000500500000000
00000000500100600bbb88800500100100600bbb88800500100100600bbb88800500100100600bbb888005001005000500000000000000000000500500000000
00000000500100600030088805001001006000300888050010010060003008880500100100600030088805001005000500000000000000000000500500000000
00000000500100600030008885001001006000300088850010010060003000888500100100600030008885001005000500000000000000000000500500000000
00000000500100600000006888001001006000000068880010010060000000688800100100600000006888001005000580000000000000000000500500000000
00000000500100066666666d8800100100066666666d8800100100066666666d8800100100066666666d88001005000507777770000000000000500500000000
00000000500100000000000008001001000000000000080010010000000000000800100100000000000008001005000506000700000000000500500500000000
00000000500110000000000000011001100000000000000110011000000000000001100110000000000000011005000506007000000000000000500500000000
00000000500111111111111111111001111111111111111110011111111111111111100111111111111111111005000506060600000000000000500500000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000506606670555555555555500500000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000770000000000000000500000000
00000000555555555555555555555555555555555555555500555555555555555555555555555555555555555555000000000000000000000000000500000000
00000000500000000000000000000000000000000000000500000000000000000000000000000000000000000005000000000000000000000000000500000000
00000000500555505500055550500505555055550555500500000000000000000000000000000000000000000005000000000000000000000000000500000000
00000000500550005500055050550505550055050555000500000000000000000000000000000000000000000000000000000000000000000000000500000000
00000000500555005500055050555505500055500055500500000000000000000000000000000000000000000000000000000000000000000000000500000000
00000000500550005555055550555505555055050555500555555555555555555555555555555555555555555555000555555555555555555555500500000000
00000000500000000000000000000000000000000000000000000000000000000000000000000000000000000005000500000000000000000000500500000000
00000000500000000000000000000000000000000000000000000000000000000000000000000000000000000005000500000000000000000000500500000000
00000000500111111111111111111001111111111111111110011111111111111111100111111111111111111005000500500000000000000500500500000000
00000000500110000000000000011001100000000000000110011000000000000001100110000000000000011005000500000000000000000000500500000000
00000000500100800000000000001001008000000000000010010080000000000000100100800000000000001005000500000000000000000000500500000000
00000000500100886666666000001001008866666660000010010088666666600000100100886666666000001005000500000000000000000000500500000000
00000000500100888000000660001001008880000006600010010088800000066000100100888000000660001005000500000000000000000000500500000000
00000000500100688800006005001001006888000060050010010068880000600500100100688800006005001005000500000000000000000000500500000000
00000000500100f0888000f00500100100f0888000f00500100100f0888000f00500100100f0888000f005001005000500000000000000000000500500000000
000000005001000ff888ff0005001001000ff888ff0005001001000ff888ff0005001001000ff888ff0005001005000500000000000000000000500500000000
00000000500100d0008880d00500100100d0008880d00500100100d0008880d00500100100d0008880d005001005000500000000000000000000500500000000
00000000500100d0bb0888d00500100100d0bb0888d00500100100d0bb0888d00500100100d0bb0888d005001005000500000000000000000000500500000000
00000000500100600bbb88800500100100600bbb88800500100100600bbb88800500100100600bbb888005001005000500000000000000000000500500000000
00000000500100600030088805001001006000300888050010010060003008880500100100600030088805001005000500000000000000000000500500000000
00000000500100600030008885001001006000300088850010010060003000888500100100600030008885001005000500000000000000000000500500000000
00000000500100600000006888001001006000000068880010010060000000688800100100600000006888001005000500000000000000000000500500000000
00000000500100066666666d8800100100066666666d8800100100066666666d8800100100066666666d88001005000500000000000000000000500500000000
00000000500100000000000008001001000000000000080010010000000000000800100100000000000008001005000500500000000000000500500500000000
00000000500110000000000000011001100000000000000110011000000000000001100110000000000000011005000500000000000000000000500500000000
00000000500111111111111111111001111111111111111110011111111111111111100111111111111111111005000500000000000000000000500500000000
00000000500000000000000000000000000000000000000000000000000000000000000000000000000000000005000555555555555555555555500500000000
00000000500000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000500000000
00000000555555555555555555555555555555555555555555555555555555555555555555555555555555555555000000000000000000000000000500000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000500000000000000000000500500000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005555555555555555550000500000000
00000050000000555555555555555555555555555555555555555555555555555555555555555555555555555555000005000000000000000050000500000000
00000555555500500000000000000000000000000000000000000000000000000050000000000000000000000005000005055500550505505050000500000000
00005555555550500000000000000000000000000000000000000000000000000050000000000000000000000005000005050550550505505050000500000000
00000555555550500808008808080000088808880888000008880808080008000050000000000000000000000005000005055050555505555050000500000000
00000050000150500808080808080000080808080800000008000808080008000050000000000000000000000005000005055550555500550050000500000000
00000000001110500888080808080000088808800880000008800808080008000050000000000000000000000005000005000000000000000050000500000000
00000111111100500008080808080000080808080800000008000808080008000050000000000000000000000005000005555555555555555550000500000000
00000111111000500888088000880000080808080888000008000088088808880050000000000000000000000005000500000000000000000000500500000000
00000000000000500000000000000000000000000000000000000000000000000050000000000000000000000005000000000000000000000000000500000000
00000000000000555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555500000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__sfx__
00070000040500a05011050260501b0500705014050210502a050270501e050130500605005050150501e050160500c0500a0500e05014050200502705028050210500f0500e050140501b050230502a05027050
00100000000001f6501e6501e6501d6501d6501d6501d6501d6501e6501f650216502265023650000002565026650276502765027650246501f650136501265012650126501565018650166501e6500000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000023650236502365025650000002765000000000002a650000002c650000002f6502f6502c65000000276500000000000226501e6501d6501c6501c6501d6501f650216500000026650286502565000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000e1500e1500e15017650221501c1501815020250202501e250141501d2501b2501a2500c1500c1500d1500e15012150171501d1502115025150191500715007150091501c65024650000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001a6501a6501a6501a6501b6501c6501d6501d650000001a65017650146501365013650000001365000000146500000015650000000000000000156500000000000000001565000000000001565015650
