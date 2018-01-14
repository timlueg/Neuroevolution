package ch.idsia.agents.controllers.examples;

import java.util.Random;

import ch.idsia.agents.AgentOptions;
import ch.idsia.agents.IAgent;
import ch.idsia.agents.controllers.MarioHijackAIBase;
import ch.idsia.benchmark.mario.MarioSimulator;
import ch.idsia.benchmark.mario.engine.input.MarioInput;
import ch.idsia.benchmark.mario.options.FastOpts;
import com.mathworks.engine.MatlabEngine;


public class Agent_NEAT extends MarioHijackAIBase implements IAgent {

	@Override
	public void reset(AgentOptions options) {
		super.reset(options);
	}

	@Override
	public MarioInput actionSelectionAI() {
		control.jump();
		control.runRight();
		return action;
	}

	public static void main(String[] args) throws Exception {
		// USE WORLD WITH NON-FLAT GROUND WITHOUT ENEMIES
		String options = FastOpts.VIS_ON_2X + FastOpts.LEVEL_02_JUMPING;
		MarioSimulator simulator = new MarioSimulator(options);
		IAgent agent = new Agent_NEAT();

		simulator.run(agent);

		System.exit(0);

		MatlabEngine eng = MatlabEngine.connectMatlab(MatlabEngine.findMatlab()[0]);
		eng.putVariable("x", 400);
		eng.close();

	}

}
