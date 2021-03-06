-- Test Query - Custom Relatory
SELECT DISTINCT S.COD_TAB || '-' || S.COD_SERV Id,
                S.COD_TAB CodTab,
                S.COD_SERV CodServico,
                S.DESCRICAO Descricao,
                NVL(O.DEFINE_DENTE, 'F') DefineDente,
                GET_DEFAULT_DENTE(S.COD_TAB, S.COD_SERV) DefaultDente,
                NVL(O.DEFINE_REGIAO, 'F') DefineRegiao,
                GET_DEFAULT_REGIAO_DENTE(S.COD_TAB, S.COD_SERV) DefaultRegiao,
                NVL(O.DEFINE_FACE, 'F') DefineFace,
                GET_DEFAULT_FACE_DENTE(S.COD_TAB, S.COD_SERV) DefaultFace,
                DECODE(NVL(GE.OBRIGA_LAUDO, 'F'),
                       'F',
                       S.LAUDO,
                       GE.OBRIGA_LAUDO) ObrigaLaudo,
                DECODE(UTILIZA_PERICIA_GTO(&TIPO_PRESTADOR,
                                           &COD_PRESTADOR,
                                           S.COD_TAB,
                                           S.COD_SERV,
                                           'T'),
                       'F',
                       UTILIZA_PERICIA_GTO(&TIPO_PRESTADOR,
                                           &COD_PRESTADOR,
                                           S.COD_TAB,
                                           S.COD_SERV,
                                           'F'),
                       UTILIZA_PERICIA_GTO(&TIPO_PRESTADOR,
                                           &COD_PRESTADOR,
                                           S.COD_TAB,
                                           S.COD_SERV,
                                           'T')) ObrigaPericia,
                UTILIZA_PERICIA_GTO(&TIPO_PRESTADOR,
                                    &COD_PRESTADOR,
                                    S.COD_TAB,
                                    S.COD_SERV,
                                    'T') ObrigaPericiaInicial,
                UTILIZA_PERICIA_GTO(&TIPO_PRESTADOR,
                                    &COD_PRESTADOR,
                                    S.COD_TAB,
                                    S.COD_SERV,
                                    'F') ObrigaPericiaFinal,
                O.OBRIGA_RAIOX_PERICIA_INICIAL ObrigaRaioXNaPericiaInicial,
                O.OBRIGA_RAIOX_PERICIA_FINAL ObrigaRaioXNaPericiaFinal,
                GET_LIBERA_RESTRICAO_WEB(&TIPO_PRESTADOR,
                                         &COD_PRESTADOR,
                                         910,
                                         S.COD_SERV,
                                         T.COD_TAB,
                                         'F',
                                         &COD_PLANO) ValidaRestricaoLaudo,
                GET_LIBERA_RESTRICAO_WEB(&TIPO_PRESTADOR,
                                         &COD_PRESTADOR,
                                         1287,
                                         S.COD_SERV,
                                         T.COD_TAB,
                                         'F',
                                         &COD_PLANO) ValidaRestricaoPericia,
                NVL(CALCULAVALOR(S.COD_TAB,
                                 S.COD_SERV,
                                 &CODSEG,
                                 &TIPO_PRESTADOR,
                                 &COD_PRESTADOR,
                                 &DT_EMISSAO,
                                 DECODE(&TIPO_PRESTADOR, 0, 2, 2, 3)),
                    0) Valor,
                S.EXIGE_VALOR_WEB_GTO ExigeValor,
                rank() over(PARTITION BY S.COD_SERV ORDER BY A.PRIORIDADE) RANK
  FROM IM_TTAB T,
       IM_TSERV S,
       IM_SVESP SE,
       IM_SERV_ODONTO O,
       GTO_ESPECIALIDADE GE,
       (SELECT COD_TAB, PRIORIDADE
          FROM IM_TAB_PRIORIDADE A
         WHERE A.COD_ENT = &COD_PRESTADOR
           AND A.TIPO_ENT = &TIPO_PRESTADOR) A
 WHERE T.COD_TAB = S.COD_TAB
   AND T.COD_TAB = A.COD_TAB(+)
   AND T.COD_TIPO_TABELA = 2
   AND S.COD_SERV2 = &COD_SERV2
   AND SE.COD_TAB(+) = S.COD_TAB
   AND SE.COD_SERV(+) = S.COD_SERV
   AND GE.COD_ESPM(+) = SE.COD_ESPM
   AND O.COD_SERV(+) = S.COD_SERV
   AND O.COD_TAB(+) = S.COD_TAB
   AND (S.NAO_EXIBE_PROC_WEB_GTO = 'F' OR S.NAO_EXIBE_PROC_WEB_GTO IS NULL)
