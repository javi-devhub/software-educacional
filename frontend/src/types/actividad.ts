export type SeccionCapitulo11 = 
  | 'Tablas' 
  | 'Pictogramas' 
  | 'Gráficos de barra' 
  | 'Interpretar gráficos' 
  | 'Cierre';

export interface FilaDato {
  categoria: string;
  total?: number;
  cantidad?: number;
  simbolos?: number;
}

export interface RecursoActividadCap11 {
  fuente: string;
  capitulo: number;
  pagina: number;
  seccion: SeccionCapitulo11;
  tipo_mecanica: string;
  datos: {
    titulo?: string;
    escala?: number;
    escala_eje?: number;
    simbolo?: string;
    filas?: FilaDato[];
    preguntas?: Array<{ p: string; r: string }>;
    [key: string]: any;
  };
}