import json
import re
import unittest
from copy import deepcopy
from pathlib import Path

from actividades import preparar_actividades


def catalogo_original():
    source = (Path(__file__).parent.parent / 'database' / 'datos_matematica.sql').read_text(encoding='utf-8')
    filas = []
    for titulo, descripcion, recurso, tipo in re.findall(r"\('([^']*)', '([^']*)', '(\{[^\n]*\})', @(t_\w+)\)", source):
        filas.append(dict(id_contenido=len(filas) + 1, titulo=titulo, descripcion=descripcion,
                          recurso=recurso, estado='activo', tipo_etapa=tipo, oas='OA 25'))
    return filas


class CatalogoTest(unittest.TestCase):
    def test_clasifica_todo_el_catalogo_sin_perder_actividades(self):
        actividades = preparar_actividades(catalogo_original())
        self.assertEqual(len(actividades), 36)
        cantidades = {seccion: sum(a.seccion == seccion for a in actividades) for seccion in {a.seccion for a in actividades}}
        self.assertEqual(cantidades, {'Tablas': 6, 'Pictogramas': 4, 'Gráficos de barra': 9,
                                     'Interpretar gráficos': 9, 'Diagramas de puntos': 3,
                                     'Experimentos aleatorios': 2, 'Cierre': 3})
        self.assertEqual([a.pagina for a in actividades], sorted(a.pagina for a in actividades))

    def test_resuelve_referencias_y_conserva_escalas(self):
        actividades = preparar_actividades(catalogo_original())
        por_pagina = {a.pagina: a for a in actividades}
        for pagina, origen in [(395, 394), (399, 398), (411, 410)]:
            self.assertEqual(por_pagina[pagina].datos['filas'], por_pagina[origen].datos['filas'])
        self.assertEqual(por_pagina[395].datos['valores_simbolo'], [2, 4])
        self.assertEqual(por_pagina[403].datos['escala'], 3)
        self.assertEqual(por_pagina[407].datos['orientacion'], 'horizontal')

    def test_no_duplica_ni_confunde_actividades_de_la_misma_pagina(self):
        filas = catalogo_original()
        duplicado = deepcopy(filas[0])
        duplicado['id_contenido'] = 999
        filas.append(duplicado)
        actividades = preparar_actividades(filas)
        self.assertEqual(len(actividades), 36)
        self.assertEqual(sum(a.pagina == 412 for a in actividades), 2)
        self.assertEqual(sum(a.pagina == 416 for a in actividades), 2)

    def test_excluye_inactivas_y_otros_capitulos(self):
        filas = catalogo_original()
        filas[0]['estado'] = 'inactivo'
        recurso = json.loads(filas[1]['recurso'])
        recurso['capitulo'] = 12
        filas[1]['recurso'] = json.dumps(recurso)
        self.assertEqual(len(preparar_actividades(filas)), 34)


if __name__ == '__main__':
    unittest.main()
