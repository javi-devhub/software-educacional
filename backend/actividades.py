"""Adaptación del catálogo original del capítulo 11 para la interfaz."""
import json
from copy import deepcopy

from schemas import ActividadResponse


def seccion_capitulo(recurso, titulo):
    pagina = recurso.get("pagina", 0) or 0
    if pagina >= 419:
        return "Cierre"
    if pagina in (414, 415):
        return "Experimentos aleatorios"
    if pagina in (412, 413):
        return "Diagramas de puntos"
    if ("interpret" in titulo.casefold() and pagina >= 406) or pagina in (416, 417, 418):
        return "Interpretar gráficos"
    if 388 <= pagina <= 393:
        return "Tablas"
    if 394 <= pagina <= 397:
        return "Pictogramas"
    if 398 <= pagina <= 410:
        return "Gráficos de barra"
    return recurso.get("seccion") or "Tablas"


def preparar_actividades(filas):
    recursos = {
        fila["id_contenido"]: json.loads(fila["recurso"])
        if isinstance(fila["recurso"], str) else fila["recurso"]
        for fila in filas
    }
    por_pagina = {}
    for recurso in recursos.values():
        if recurso.get("datos", {}).get("filas"):
            por_pagina.setdefault(recurso.get("pagina"), recurso["datos"])

    resultado = []
    vistos = set()
    for fila in filas:
        recurso = recursos[fila["id_contenido"]]
        if recurso.get("capitulo") != 11 or fila.get("estado", "activo") != "activo":
            continue
        # Una página puede tener varias actividades distintas (412 y 416).
        identidad = (fila["titulo"].strip().casefold(), recurso.get("pagina"),
                     json.dumps(recurso.get("datos", {}), sort_keys=True, ensure_ascii=False))
        if identidad in vistos:
            continue
        vistos.add(identidad)
        datos = deepcopy(recurso.get("datos", {}))
        referencia = datos.get("mismos_datos_que_pagina")
        if referencia in por_pagina:
            datos = {**deepcopy(por_pagina[referencia]), **datos}
        datos.setdefault("titulo", datos.get("titulo_tabla") or datos.get("titulo_grafico") or fila["titulo"])
        texto = fila["titulo"].casefold()
        if "diagrama de puntos" in texto:
            grafico = "puntos"
        elif "pictograma" in texto or "valor_simbolo" in datos:
            grafico = "pictograma"
        else:
            grafico = "barras"
        datos.setdefault("tipo_grafico", grafico)
        datos.setdefault("escala", datos.get("graduacion", 1))
        if recurso.get("pagina") in (400, 401):
            datos.setdefault("orientaciones", ["vertical", "horizontal"])
        if recurso.get("pagina") in (407, 408):
            datos.setdefault("orientacion", "horizontal")
        resultado.append(ActividadResponse(
            id_contenido=fila["id_contenido"], titulo=fila["titulo"],
            descripcion=fila["descripcion"],
            seccion=seccion_capitulo(recurso, fila["titulo"]),
            tipo_mecanica=recurso.get("tipo_mecanica"), pagina=recurso.get("pagina"),
            datos=datos, tipo_etapa=fila["tipo_etapa"],
            oa_asociados=sorted(set(oa.strip() for oa in (fila.get("oas") or "").split(",") if oa.strip())),
        ))
    return sorted(resultado, key=lambda a: (a.pagina or 0, a.id_contenido))
