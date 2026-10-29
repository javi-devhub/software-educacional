import test from 'node:test'
import assert from 'node:assert/strict'
import { answerChoices } from './playful.js'

test('las tarjetas incluyen una sola respuesta correcta, sin negativos ni repetidos', () => {
  for (const answer of [0, 1, 2, 5, 27, 500, 1930]) {
    for (let index = 0; index < 16; index++) {
      const choices = answerChoices(answer, index)
      assert.equal(choices.length, 4)
      assert.equal(new Set(choices).size, 4)
      assert.equal(choices.filter(value => value === answer).length, 1)
      assert.ok(choices.every(value => Number.isInteger(value) && value >= 0))
      assert.equal(choices[index % 4], answer)
      assert.deepEqual(choices, answerChoices(answer, index))
    }
  }
})
